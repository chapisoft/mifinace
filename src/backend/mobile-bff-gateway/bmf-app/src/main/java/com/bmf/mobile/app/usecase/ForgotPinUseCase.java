package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ResetPinRequest;
import com.bmf.mobile.app.dto.request.SendOtpRequest;
import com.bmf.mobile.app.dto.request.VerifyOtpRequest;
import com.bmf.mobile.app.dto.response.AuthResponse;
import com.bmf.mobile.app.dto.response.SendOtpResponse;
import com.bmf.mobile.app.dto.response.VerifyOtpResponse;
import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.entity.MobileDevice;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.OtpManagementPort;
import com.bmf.mobile.domain.port.PasswordEncoderPort;
import com.bmf.mobile.domain.port.StepUpTokenClaims;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.port.TokenProviderPort;
import com.bmf.mobile.domain.repository.AppUserRepository;
import com.bmf.mobile.domain.repository.CustomerRepository;
import com.bmf.mobile.domain.repository.MobileDeviceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * UseCase xử lý luồng Quên mã PIN và Đặt lại PIN mới bảo mật qua OTP cho cả Khách hàng và Agent (Trưởng nhóm/cụm):
 * 1. Gửi OTP đến số điện thoại đã kích hoạt trong hồ sơ KH_THANHVIEN.
 * 2. Xác thực OTP và cấp Step-Up Token (RESET_PIN) dùng 1 lần.
 * 3. Băm PIN mới bằng BCrypt, cập nhật AppUser, reset trạng thái khóa PIN và đăng nhập.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ForgotPinUseCase {

    private final CustomerRepository customerRepository;
    private final AppUserRepository appUserRepository;
    private final MobileDeviceRepository deviceRepository;
    private final OtpManagementPort otpManagementPort;
    private final PasswordEncoderPort passwordEncoderPort;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;

    private static final String PURPOSE_RESET_PIN = "RESET_PIN";
    private static final int OTP_TTL_SECONDS = 120;
    private static final String BEARER_TYPE = "Bearer";

    public SendOtpResponse sendForgotPinOtp(SendOtpRequest request) {
        String identifier = request.getIdentifier().trim();
        UserType userType = request.getUserType();

        log.info("Requesting Forgot PIN OTP: identifier={}, userType={}", identifier, userType);

        CustomerMember customer = findCustomer(identifier);
        String customerCode = customer.getCustomerCode(); // Ma_ThanhVien

        if (userType == UserType.AGENT) {
            boolean isLeader = customerRepository.isGroupOrCenterLeader(
                    customerCode, customer.getFullName(), customer.getGroupCode(), customer.getCenterCode());
            if (!isLeader) {
                log.warn("Cannot reset Agent PIN for non-leader member: customerCode={}", customerCode);
                throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
            }
        }

        // Bắt buộc tài khoản đã từng kích hoạt mới được quên PIN
        AppUser appUser = appUserRepository.findByBusinessId(customerCode, userType)
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED));

        if (!appUser.isActivated()) {
            log.warn("Cannot reset PIN for unactivated account: customerCode={}", customerCode);
            throw new BusinessException(ErrorCode.ERR_ACCOUNT_NOT_ACTIVATED);
        }

        String phoneNumber = customer.getPhoneNumber();
        if (phoneNumber == null || phoneNumber.isBlank()) {
            throw new BusinessException(ErrorCode.ERR_PARAMETERS_INVALID);
        }

        otpManagementPort.generateAndStoreOtp(customerCode, PURPOSE_RESET_PIN, phoneNumber, OTP_TTL_SECONDS);

        return SendOtpResponse.builder()
                .identifier(customerCode)
                .maskedPhone(maskPhoneNumber(phoneNumber))
                .expiresIn(OTP_TTL_SECONDS)
                .cooldownSeconds(60)
                .build();
    }

    public VerifyOtpResponse verifyForgotPinOtp(VerifyOtpRequest request) {
        String identifier = request.getIdentifier().trim();
        UserType userType = request.getUserType();

        log.info("Verifying Forgot PIN OTP: identifier={}, userType={}", identifier, userType);

        CustomerMember customer = findCustomer(identifier);
        String customerCode = customer.getCustomerCode();

        otpManagementPort.verifyOtp(customerCode, PURPOSE_RESET_PIN, request.getOtpCode());

        String resetPinToken = otpManagementPort.generateStepUpToken(customerCode, userType, PURPOSE_RESET_PIN, customerCode);

        return VerifyOtpResponse.builder()
                .stepUpToken(resetPinToken)
                .purpose(PURPOSE_RESET_PIN)
                .expiresIn(600)
                .build();
    }

    @Transactional
    public AuthResponse resetPin(ResetPinRequest request) {
        log.info("Resetting PIN for account: deviceId={}, platform={}", request.getDeviceId(), request.getPlatform());

        StepUpTokenClaims claims = otpManagementPort.validateAndConsumeStepUpToken(
                request.getResetPinToken(), PURPOSE_RESET_PIN);

        String customerCode = claims.getBusinessId(); // Ma_ThanhVien
        UserType userType = claims.getUserType();

        CustomerMember customer = customerRepository.findByCustomerCode(customerCode)
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_USER_NOT_FOUND));

        // Băm mã PIN mới bằng BCrypt
        String newPinHash = passwordEncoderPort.encode(request.getNewPinCode());

        // Cập nhật CSDL KH_THANHVIEN và SYS_APP_USER
        customerRepository.updatePinHash(customerCode, newPinHash);

        String appUserId = userType == UserType.AGENT ? ("APP-AGT-" + customerCode) : ("APP-" + customerCode);
        appUserRepository.updatePin(appUserId, newPinHash);
        appUserRepository.resetPinFailure(appUserId);

        tokenBlacklistPort.resetPinFailure(customerCode);
        tokenBlacklistPort.resetPinFailure(customer.getNrcNumber());

        // Cập nhật thiết bị
        Optional<MobileDevice> deviceOpt = deviceRepository.findByDeviceIdAndUserId(request.getDeviceId(), customerCode);
        MobileDevice device;
        if (deviceOpt.isPresent()) {
            device = deviceOpt.get();
            device.recordActivity(null, request.getAppVersion());
        } else {
            device = MobileDevice.builder()
                    .deviceId(request.getDeviceId())
                    .userId(customerCode)
                    .userType(userType)
                    .platform(request.getPlatform())
                    .appVersion(request.getAppVersion())
                    .active(true)
                    .lastActiveTime(LocalDateTime.now())
                    .createdTime(LocalDateTime.now())
                    .updatedTime(LocalDateTime.now())
                    .build();
        }
        deviceRepository.save(device);

        // Sinh phiên đăng nhập mới
        String accessToken = tokenProviderPort.generateAccessToken(customerCode, userType, request.getDeviceId(), request.getPlatform());
        String refreshToken = tokenProviderPort.generateRefreshToken();
        tokenBlacklistPort.storeRefreshToken(refreshToken, customerCode, userType, request.getDeviceId(), request.getPlatform());

        log.info("PIN reset successfully and new session issued: customerCode={}, userType={}", customerCode, userType);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(BEARER_TYPE)
                .expiresIn(tokenProviderPort.getAccessTokenExpirationSeconds())
                .userType(userType)
                .userId(customerCode)
                .fullName(customer.getFullName())
                .groupCode(customer.getGroupCode())
                .centerCode(customer.getCenterCode())
                .township(customer.getTownship())
                .deviceId(device.getDeviceId())
                .platform(device.getPlatform())
                .deviceActive(device.isActive())
                .build();
    }

    private CustomerMember findCustomer(String identifier) {
        return customerRepository.findByCustomerCode(identifier)
                .or(() -> customerRepository.findByNrcNumber(identifier))
                .or(() -> customerRepository.findByPhoneNumber(identifier))
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_USER_NOT_FOUND));
    }

    private String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 7) {
            return "09****" + (phone != null && phone.length() > 3 ? phone.substring(phone.length() - 3) : "xxx");
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 3);
    }
}
