package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CheckAccountRequest;
import com.bmf.mobile.app.dto.response.CheckAccountResponse;
import com.bmf.mobile.domain.entity.AppUser;
import com.bmf.mobile.domain.entity.CustomerMember;
import com.bmf.mobile.domain.enums.ErrorCode;
import com.bmf.mobile.domain.enums.UserType;
import com.bmf.mobile.domain.exception.BusinessException;
import com.bmf.mobile.domain.port.TokenBlacklistPort;
import com.bmf.mobile.domain.repository.AppUserRepository;
import com.bmf.mobile.domain.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * UseCase kiểm tra định danh tài khoản trong hệ thống Core Banking (bảng KH_THANHVIEN) và xác định trạng thái kích hoạt App.
 * CẤM người dùng đăng ký tự do; chỉ cho phép kích hoạt tài khoản đã có hồ sơ Core Banking.
 * Dùng Ma_ThanhVien làm username/key khóa ngoại chính cho cả Khách hàng và Agent (Trưởng nhóm/cụm).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CheckAccountUseCase {

    private final CustomerRepository customerRepository;
    private final AppUserRepository appUserRepository;
    private final TokenBlacklistPort tokenBlacklistPort;

    public CheckAccountResponse checkAccount(CheckAccountRequest request) {
        String identifier = request.getIdentifier().trim();
        UserType userType = request.getUserType();

        log.info("Checking account status: identifier={}, userType={}", identifier, userType);

        // 1. Tìm hồ sơ khách hàng trong Core Banking (KH_THANHVIEN) theo Ma_ThanhVien, NRC hoặc Số điện thoại
        Optional<CustomerMember> customerOpt = customerRepository.findByCustomerCode(identifier);
        if (customerOpt.isEmpty()) {
            customerOpt = customerRepository.findByNrcNumber(identifier);
        }
        if (customerOpt.isEmpty()) {
            customerOpt = customerRepository.findByPhoneNumber(identifier);
        }

        if (customerOpt.isEmpty()) {
            log.warn("Account check failed - not found in KH_THANHVIEN: identifier={}", identifier);
            throw new BusinessException(ErrorCode.ERR_USER_NOT_FOUND);
        }

        CustomerMember customer = customerOpt.get();
        if (!customer.isActive()) {
            log.warn("Customer account is inactive/disabled in Core: customerCode={}", customer.getCustomerCode());
            throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
        }

        // 2. Nếu đăng nhập với vai trò AGENT, kiểm tra xem khách hàng này có phải là Trưởng nhóm hoặc Trưởng cụm không
        if (userType == UserType.AGENT) {
            boolean isLeader = customerRepository.isGroupOrCenterLeader(
                    customer.getCustomerCode(),
                    customer.getFullName(),
                    customer.getGroupCode(),
                    customer.getCenterCode()
            );

            if (!isLeader) {
                log.warn("Customer is not assigned as Group Leader / Center Chief: customerCode={}", customer.getCustomerCode());
                throw new BusinessException(ErrorCode.ERR_FORBIDDEN);
            }
        }

        // 3. Tra cứu trạng thái trong bảng SYS_APP_USER theo Business_Id (Ma_ThanhVien)
        Optional<AppUser> appUserOpt = appUserRepository.findByBusinessId(customer.getCustomerCode(), userType);
        if (appUserOpt.isEmpty()) {
            appUserOpt = appUserRepository.findByIdentifier(customer.getCustomerCode(), userType);
        }

        boolean isActivated = appUserOpt.isPresent() && appUserOpt.get().isActivated() && appUserOpt.get().getPinHash() != null;
        boolean isBiometric = appUserOpt.isPresent() && appUserOpt.get().isBiometricEnabled();
        boolean isLocked = tokenBlacklistPort.isPinLocked(customer.getCustomerCode())
                || tokenBlacklistPort.isPinLocked(customer.getNrcNumber());

        return CheckAccountResponse.builder()
                .status(isActivated ? "ACTIVATED" : "NOT_ACTIVATED")
                .identifier(customer.getCustomerCode()) // Dùng Ma_ThanhVien làm username chính
                .businessId(customer.getCustomerCode())
                .userType(userType)
                .fullName(customer.getFullName())
                .maskedPhone(maskPhoneNumber(customer.getPhoneNumber()))
                .nrcNumber(customer.getNrcNumber())
                .activated(isActivated)
                .biometricEnabled(isBiometric)
                .pinLocked(isLocked)
                .build();
    }

    private String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 7) {
            return "09****" + (phone != null && phone.length() > 3 ? phone.substring(phone.length() - 3) : "xxx");
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 3);
    }
}
