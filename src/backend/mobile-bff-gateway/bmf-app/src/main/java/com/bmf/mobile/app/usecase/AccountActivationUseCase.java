package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ActivateAccountRequest;
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
 * UseCase xử lý toàn bộ luồng Kích hoạt tài khoản ứng dụng Mobile App lần đầu (Customer & Agent):
 * 1. Gửi OTP bảo mật đến số điện thoại trong hồ sơ Core Banking (KH_THANHVIEN).
 * 2. Xác thực OTP và cấp Step-Up Token dùng 1 lần (TTL 10 phút).
 * 3. Thiết lập mã PIN 6 số (băm BCrypt), kích hoạt AppUser (dùng Ma_ThanhVien làm username/key khóa ngoại) và sinh phiên đăng nhập.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AccountActivationUseCase {

    private final CustomerRepository customerRepository;
    private final AppUserRepository appUserRepository;
    private final MobileDeviceRepository deviceRepository;
    private final OtpManagementPort otpManagementPort;
    private final PasswordEncoderPort passwordEncoderPort;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;

    private static final String PURPOSE_ACTIVATION = "ACTIVATION";
    private static final int OTP_TTL_SECONDS = 120;
    private static final String BEARER_TYPE = "Bearer";

    public SendOtpResponse sendActivationOtp(SendOtpRequest request) {
        String identifier = request.getIdentifier().trim();
        UserType userType = request.getUserType();

        log.info("Requesting activation OTP: identifier={}, userType={}", identifier, userType);

        CustomerMember customer = findCustomer(identifier);
        if (userType == UserType.AGENT) {
            boolean isLeader = customerRepository.isGroupOrCenterLeader(
                    customer.getCustomerCode(), customer.getFullName(), customer.getGroupCode(), customer.getCenterCode());
            if (!isLeader) {
                log.warn("Account is not assigned as Agent/Leader: customerCode={}", customer.getCustomerCode());
                throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
            }
        }

        checkNotAlreadyActivated(customer.getCustomerCode(), userType);

        String phoneNumber = customer.getPhoneNumber();
        if (phoneNumber == null || phoneNumber.isBlank()) {
            log.warn("Account has no registered phone number in Core: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_PARAMETERS_INVALID);
        }

        // Sinh OTP bảo mật trên Redis (Dùng Ma_ThanhVien làm identifier chuẩn)
        otpManagementPort.generateAndStoreOtp(customer.getCustomerCode(), PURPOSE_ACTIVATION, phoneNumber, OTP_TTL_SECONDS);

        return SendOtpResponse.builder()
                .identifier(customer.getCustomerCode())
                .maskedPhone(maskPhoneNumber(phoneNumber))
                .expiresIn(OTP_TTL_SECONDS)
                .cooldownSeconds(60)
                .build();
    }

    public VerifyOtpResponse verifyActivationOtp(VerifyOtpRequest request) {
        String identifier = request.getIdentifier().trim();
        UserType userType = request.getUserType();

        log.info("Verifying activation OTP: identifier={}, userType={}", identifier, userType);

        CustomerMember customer = findCustomer(identifier);
        String businessId = customer.getCustomerCode(); // Ma_ThanhVien

        // Xác thực mã OTP trên Redis
        otpManagementPort.verifyOtp(businessId, PURPOSE_ACTIVATION, request.getOtpCode());

        // Cấp Step-Up Token dùng 1 lần (10 phút)
        String stepUpToken = otpManagementPort.generateStepUpToken(businessId, userType, PURPOSE_ACTIVATION, businessId);

        return VerifyOtpResponse.builder()
                .stepUpToken(stepUpToken)
                .purpose(PURPOSE_ACTIVATION)
                .expiresIn(600)
                .build();
    }

    @Transactional
    public AuthResponse activateAccount(ActivateAccountRequest request) {
        log.info("Activating app account with PIN setup: deviceId={}, platform={}",
                request.getDeviceId(), request.getPlatform());

        // 1. Xác thực và thu hồi (Consume) Step-Up Token (Bảo đảm One-time Token)
        StepUpTokenClaims claims = otpManagementPort.validateAndConsumeStepUpToken(
                request.getActivationToken(), PURPOSE_ACTIVATION);

        String customerCode = claims.getBusinessId(); // Ma_ThanhVien
        UserType userType = claims.getUserType();

        CustomerMember customer = customerRepository.findByCustomerCode(customerCode)
                .orElseThrow(() -> new BusinessException(ErrorCode.ERR_USER_NOT_FOUND));

        // 2. Băm mã PIN bằng BCrypt (Cost 10)
        String pinHash = passwordEncoderPort.encode(request.getPinCode());

        // 3. Đồng bộ mã PIN vào bảng KH_THANHVIEN
        customerRepository.updatePinHash(customerCode, pinHash);

        // 4. Tạo hoặc cập nhật tài khoản AppUser liên kết khóa ngoại Ma_ThanhVien
        String appUserId = userType == UserType.AGENT ? ("APP-AGT-" + customerCode) : ("APP-" + customerCode);

        AppUser appUser = AppUser.builder()
                .userId(appUserId)
                .userType(userType)
                .businessId(customerCode) // Khóa ngoại trỏ KH_THANHVIEN.Ma_ThanhVien
                .identifierKey(customerCode) // Username chính là Ma_ThanhVien
                .phoneNumber(customer.getPhoneNumber())
                .nrcNumber(customer.getNrcNumber())
                .fullName(customer.getFullName())
                .pinHash(pinHash)
                .activated(true)
                .activatedTime(LocalDateTime.now())
                .biometricEnabled(request.isEnableBiometric())
                .status("ACTIVE")
                .failedPinAttempts(0)
                .lastLoginTime(LocalDateTime.now())
                .build();

        appUserRepository.save(appUser);

        // 5. Ghi nhận thông tin thiết bị
        Optional<MobileDevice> existingDeviceOpt = deviceRepository.findByDeviceIdAndUserId(request.getDeviceId(), customerCode);
        MobileDevice device;
        if (existingDeviceOpt.isPresent()) {
            device = existingDeviceOpt.get();
            device.setDeviceName(request.getDeviceName());
            device.setOsVersion(request.getOsVersion());
            device.setPublicKey(request.getPublicKey());
            device.recordActivity(request.getPushToken(), request.getAppVersion());
        } else {
            device = MobileDevice.builder()
                    .deviceId(request.getDeviceId())
                    .userId(customerCode)
                    .userType(userType)
                    .platform(request.getPlatform())
                    .deviceName(request.getDeviceName())
                    .osVersion(request.getOsVersion())
                    .appVersion(request.getAppVersion())
                    .pushToken(request.getPushToken())
                    .publicKey(request.getPublicKey())
                    .active(true)
                    .lastActiveTime(LocalDateTime.now())
                    .createdTime(LocalDateTime.now())
                    .updatedTime(LocalDateTime.now())
                    .build();
        }
        deviceRepository.save(device);

        // 6. Cấp cặp Access Token & Refresh Token chính thức
        String accessToken = tokenProviderPort.generateAccessToken(customerCode, userType, request.getDeviceId(), request.getPlatform());
        String refreshToken = tokenProviderPort.generateRefreshToken();

        tokenBlacklistPort.storeRefreshToken(refreshToken, customerCode, userType, request.getDeviceId(), request.getPlatform());

        log.info("App account activated successfully: customerCode={}, userType={}, deviceId={}",
                customerCode, userType, request.getDeviceId());

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

    private void checkNotAlreadyActivated(String customerCode, UserType userType) {
        Optional<AppUser> appUserOpt = appUserRepository.findByBusinessId(customerCode, userType);
        if (appUserOpt.isPresent() && appUserOpt.get().isActivated() && appUserOpt.get().getPinHash() != null) {
            log.warn("Account is already activated: customerCode={}, userType={}", customerCode, userType);
            throw new BusinessException(ErrorCode.ERR_ACCOUNT_ALREADY_ACTIVATED);
        }
    }

    private String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 7) {
            return "09****" + (phone != null && phone.length() > 3 ? phone.substring(phone.length() - 3) : "xxx");
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 3);
    }
}
