package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.ConfirmCashHandoverRequest;
import com.bmf.mobile.app.dto.request.GenerateCashHandoverQrRequest;
import com.bmf.mobile.app.dto.response.CashHandoverQrResponse;
import com.bmf.mobile.domain.entity.CashHandover;
import com.bmf.mobile.domain.enums.CashHandoverStatus;
import com.bmf.mobile.domain.repository.CashHandoverRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CashHandoverUseCaseTest {

    @Mock
    private CashHandoverRepository cashHandoverRepository;

    @InjectMocks
    private CashHandoverUseCase cashHandoverUseCase;

    @Test
    @DisplayName("Sinh mã QR bàn giao quỹ tiền mặt cuối ngày - Ký số HMAC-SHA256 chuẩn xác")
    void generateHandoverQrSuccess() {
        GenerateCashHandoverQrRequest req = GenerateCashHandoverQrRequest.builder()
                .handoverDate("2026-09-15")
                .build();

        when(cashHandoverRepository.calculateTotalCashCollectedToday(eq("USR001"), any(LocalDate.class)))
                .thenReturn(new BigDecimal("1250000.00"));
        when(cashHandoverRepository.countTotalTransactionsToday(eq("USR001"), any(LocalDate.class)))
                .thenReturn(25);

        CashHandoverQrResponse response = cashHandoverUseCase.generateHandoverQr(req, "USR001");

        assertNotNull(response);
        assertEquals("HO-20260915-USR001", response.getHandoverId());
        assertEquals("USR001", response.getCollectorId());
        assertEquals(new BigDecimal("1250000.00"), response.getTotalAmount());
        assertEquals(25, response.getTotalTransactions());
        assertTrue(response.getQrPayload().startsWith("BMF_HANDOVER:HO-20260915-USR001|1250000.00|25|SIG:"));
        assertEquals(CashHandoverStatus.PENDING_CONFIRMATION, response.getStatus());

        verify(cashHandoverRepository).save(any(CashHandover.class));
    }

    @Test
    @DisplayName("Thủ quỹ xác nhận nhập quỹ tiền mặt thành công - Cập nhật trạng thái CONFIRMED")
    void confirmHandoverSuccess() {
        // Sinh handover hợp lệ trước
        GenerateCashHandoverQrRequest req = GenerateCashHandoverQrRequest.builder()
                .handoverDate("2026-09-15")
                .build();

        when(cashHandoverRepository.calculateTotalCashCollectedToday(eq("USR001"), any(LocalDate.class)))
                .thenReturn(new BigDecimal("1250000.00"));
        when(cashHandoverRepository.countTotalTransactionsToday(eq("USR001"), any(LocalDate.class)))
                .thenReturn(25);

        CashHandoverQrResponse qrResponse = cashHandoverUseCase.generateHandoverQr(req, "USR001");

        CashHandover existingHandover = CashHandover.builder()
                .handoverId(qrResponse.getHandoverId())
                .collectorId("USR001")
                .handoverDate(LocalDate.parse("2026-09-15"))
                .totalAmount(new BigDecimal("1250000.00"))
                .totalTransactions(25)
                .qrPayload(qrResponse.getQrPayload())
                .qrSignature(qrResponse.getQrPayload().substring(qrResponse.getQrPayload().indexOf("SIG:") + 4))
                .status(CashHandoverStatus.PENDING_CONFIRMATION)
                .build();

        when(cashHandoverRepository.findById("HO-20260915-USR001")).thenReturn(Optional.of(existingHandover));

        ConfirmCashHandoverRequest confirmReq = ConfirmCashHandoverRequest.builder()
                .handoverId("HO-20260915-USR001")
                .qrPayload(qrResponse.getQrPayload())
                .build();

        cashHandoverUseCase.confirmHandover(confirmReq, "CASHIER01");

        verify(cashHandoverRepository).updateStatus("HO-20260915-USR001", CashHandoverStatus.CONFIRMED, "CASHIER01");
    }
}
