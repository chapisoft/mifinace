package com.bmf.mobile.api.controller;

import com.bmf.mobile.app.dto.response.ApiResponse;
import com.bmf.mobile.app.service.I18nService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Controller cung cấp danh mục mạng lưới chi nhánh và điểm giao dịch vi mô.
 */
@RestController
@RequestMapping("/api/v1/branches")
@RequiredArgsConstructor
@Tag(name = "12. Branch Network & Directory", description = "Tra cứu mạng lưới chi nhánh, phòng giao dịch và điểm dịch vụ nông thôn")
public class BranchController {

    private final I18nService i18nService;

    @GetMapping
    @Operation(summary = "Lấy danh sách các chi nhánh và phòng giao dịch của BMF")
    public ResponseEntity<ApiResponse<List<BranchDto>>> getBranches() {
        List<BranchDto> branches = List.of(
                BranchDto.builder()
                        .code("BR-YGN-01")
                        .name("Chi Nhánh Trung Tâm Yangon (Head Office)")
                        .type("MAIN_BRANCH")
                        .region("Yangon")
                        .township("Dagon Township")
                        .address("Số 142 Đường Pyay, Dagon Township, Yangon")
                        .phone("01-2305899")
                        .workingHours("08:00 - 16:30 (Thứ 2 - Thứ 6)")
                        .distanceKm(1.2)
                        .isOpenNow(true)
                        .services(List.of("Giải ngân vốn", "Thu nợ MMQR & Tiền mặt", "Mở sổ tiết kiệm", "Thẩm định tín dụng", "Đổi ngoại tệ"))
                        .build(),
                BranchDto.builder()
                        .code("BR-YGN-02")
                        .name("Phòng Giao Dịch Hlaing Tharyar")
                        .type("SUB_BRANCH")
                        .region("Yangon")
                        .township("Hlaing Tharyar")
                        .address("Số 58 Khu công nghiệp Hlaing Tharyar, Yangon")
                        .phone("01-6890123")
                        .workingHours("08:00 - 16:30 (Thứ 2 - Thứ 6)")
                        .distanceKm(4.5)
                        .isOpenNow(true)
                        .services(List.of("Giải ngân tiểu thương", "Thu nợ", "Gửi tiết kiệm", "Hỗ trợ Smart OTP"))
                        .build(),
                BranchDto.builder()
                        .code("BR-YGN-03")
                        .name("Điểm Giao Dịch Xã Thanlyin")
                        .type("VILLAGE_POINT")
                        .region("Yangon")
                        .township("Thanlyin")
                        .address("Trụ sở Hợp tác xã Nông nghiệp Thanlyin, Yangon")
                        .phone("09-450123456")
                        .workingHours("08:30 - 15:30 (Thứ 3, Thứ 5 hàng tuần)")
                        .distanceKm(8.7)
                        .isOpenNow(false)
                        .services(List.of("Vay nông nghiệp", "Sinh hoạt cụm nhóm", "Thu nợ định kỳ"))
                        .build(),
                BranchDto.builder()
                        .code("BR-MDY-01")
                        .name("Chi Nhánh Mandalay Central")
                        .type("MAIN_BRANCH")
                        .region("Mandalay")
                        .township("Chanayethazan")
                        .address("Số 73 Đường 26x77, Chanayethazan, Mandalay")
                        .phone("02-4067890")
                        .workingHours("08:00 - 16:30 (Thứ 2 - Thứ 6)")
                        .distanceKm(620.0)
                        .isOpenNow(true)
                        .services(List.of("Giải ngân vốn", "Thu nợ MMQR", "Tiết kiệm vi mô", "Thẩm định hộ kinh doanh"))
                        .build(),
                BranchDto.builder()
                        .code("BR-BGO-01")
                        .name("Phòng Giao Dịch Bago City")
                        .type("SUB_BRANCH")
                        .region("Bago")
                        .township("Bago Township")
                        .address("Số 12 Đường Yangon-Mandalay, Bago")
                        .phone("052-220145")
                        .workingHours("08:00 - 16:30 (Thứ 2 - Thứ 6)")
                        .distanceKm(78.0)
                        .isOpenNow(true)
                        .services(List.of("Vay mùa vụ lúa", "Thu nợ", "Mở sổ tiết kiệm", "Hỗ trợ bồi thường"))
                        .build(),
                BranchDto.builder()
                        .code("BR-AYY-01")
                        .name("Điểm Dịch Vụ Nông Nghiệp Pathein")
                        .type("VILLAGE_POINT")
                        .region("Ayeyarwady")
                        .township("Pathein")
                        .address("Ấn số 4, Cụm Nông nghiệp Pathein, Ayeyarwady")
                        .phone("042-24567")
                        .workingHours("08:00 - 15:00 (Thứ 2 - Thứ 6)")
                        .distanceKm(185.0)
                        .isOpenNow(true)
                        .services(List.of("Vay nông nghiệp", "Thu nợ nhóm", "Tập huấn tín dụng"))
                        .build(),
                BranchDto.builder()
                        .code("BR-NPT-01")
                        .name("Phòng Giao Dịch Thủ Đô Naypyidaw")
                        .type("SUB_BRANCH")
                        .region("Naypyidaw")
                        .township("Zabuthiri")
                        .address("Khu thương mại Zabuthiri, Naypyidaw")
                        .phone("067-8109234")
                        .workingHours("08:00 - 16:30 (Thứ 2 - Thứ 6)")
                        .distanceKm(340.0)
                        .isOpenNow(true)
                        .services(List.of("Tín dụng cán bộ", "Tiết kiệm", "Dịch vụ MMQR"))
                        .build()
        );

        String message = i18nService.getMessage("msg.common.success");
        return ResponseEntity.ok(ApiResponse.ok(branches, message));
    }

    @Getter
    @Builder
    public static class BranchDto {
        private String code;
        private String name;
        private String type;
        private String region;
        private String township;
        private String address;
        private String phone;
        private String workingHours;
        private Double distanceKm;
        private Boolean isOpenNow;
        private List<String> services;
    }
}
