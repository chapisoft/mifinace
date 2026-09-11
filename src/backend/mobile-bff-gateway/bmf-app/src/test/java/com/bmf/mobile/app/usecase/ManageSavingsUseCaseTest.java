package com.bmf.mobile.app.usecase;

import com.bmf.mobile.app.dto.request.CollectSavingDepositRequest;
import com.bmf.mobile.app.dto.request.OpenSavingAccountRequest;
import com.bmf.mobile.app.dto.response.SavingAccountResponse;
import com.bmf.mobile.app.dto.response.SavingTransactionReceiptResponse;
import com.bmf.mobile.domain.entity.OutboxEvent;
import com.bmf.mobile.domain.entity.SavingAccount;
import com.bmf.mobile.domain.entity.SavingTransaction;
import com.bmf.mobile.domain.enums.RepaymentMethod;
import com.bmf.mobile.domain.enums.RepaymentStatus;
import com.bmf.mobile.domain.enums.SavingAccountStatus;
import com.bmf.mobile.domain.enums.SavingProductType;
import com.bmf.mobile.domain.enums.SavingTransactionType;
import com.bmf.mobile.domain.port.DistributedLockPort;
import com.bmf.mobile.domain.repository.OutboxEventRepository;
import com.bmf.mobile.domain.repository.SavingRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ManageSavingsUseCaseTest {

    @Mock
    private SavingRepository savingRepository;

    @Mock
    private OutboxEventRepository outboxEventRepository;

    @Mock
    private DistributedLockPort distributedLockPort;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private ManageSavingsUseCase manageSavingsUseCase;

    private SavingAccount activeAccount;

    @BeforeEach
    void setUp() {
        activeAccount = SavingAccount.builder()
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .productType(SavingProductType.ACCUMULATIVE)
                .balance(new BigDecimal("75000.00"))
                .interestRate(new BigDecimal("10.00"))
                .termMonths(6)
                .status(SavingAccountStatus.ACTIVE)
                .createdTime(LocalDateTime.now().minusMonths(1))
                .build();
    }

    @Test
    @DisplayName("Mở sổ tiết kiệm thành công - Lưu tài khoản và giao dịch nạp ban đầu")
    void openAccountSuccess() {
        OpenSavingAccountRequest req = OpenSavingAccountRequest.builder()
                .customerCode("CUST-001")
                .customerName("Daw Khin Myint")
                .productType(SavingProductType.ACCUMULATIVE)
                .initialDeposit(new BigDecimal("10000.00"))
                .termMonths(6)
                .beneficiaryName("U Aung Myo")
                .beneficiaryNrc("12/DAGAMA(N)098765")
                .build();

        SavingAccountResponse response = manageSavingsUseCase.openAccount(req, "USR001");

        assertNotNull(response);
        assertNotNull(response.getAccountNumber());
        assertEquals("CUST-001", response.getCustomerCode());
        assertEquals(SavingProductType.ACCUMULATIVE, response.getProductType());
        assertEquals(new BigDecimal("10000.00"), response.getBalance());

        verify(savingRepository).saveAccount(any(SavingAccount.class));
        verify(savingRepository).saveTransaction(any(SavingTransaction.class));
    }

    @Test
    @DisplayName("Nộp tiền gửi tiết kiệm thành công - Cộng dồn số dư và sinh Outbox Event")
    void collectDepositSuccess() throws Exception {
        CollectSavingDepositRequest req = CollectSavingDepositRequest.builder()
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .amount(new BigDecimal("5000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-SAV-001")
                .offlineTimestamp("2026-09-15T11:00:00")
                .build();

        when(savingRepository.findTransactionByIdempotencyKey("IDEM-SAV-001")).thenReturn(Optional.empty());

        when(distributedLockPort.executeWithLock(anyString(), anyLong(), anyLong(), any(TimeUnit.class), org.mockito.ArgumentMatchers.<Supplier<SavingTransactionReceiptResponse>>any()))
                .thenAnswer(invocation -> {
                    Supplier<?> action = invocation.getArgument(4);
                    return action.get();
                });

        when(savingRepository.findAccountByNumber("SA-2026-0099")).thenReturn(Optional.of(activeAccount));
        when(objectMapper.writeValueAsString(any())).thenReturn("{\"mock\":\"payload\"}");

        SavingTransactionReceiptResponse response = manageSavingsUseCase.collectDeposit(req, "USR001");

        assertNotNull(response);
        assertEquals("SA-2026-0099", response.getAccountNumber());
        assertEquals(new BigDecimal("5000.00"), response.getAmount());
        assertEquals(new BigDecimal("80000.00"), response.getNewBalance());
        assertEquals(SavingTransactionType.DEPOSIT, response.getTransactionType());
        assertEquals(RepaymentStatus.COLLECTED, response.getStatus());

        verify(savingRepository).updateAccountBalance("SA-2026-0099", new BigDecimal("80000.00"));
        verify(savingRepository).saveTransaction(any(SavingTransaction.class));
        verify(outboxEventRepository).save(any(OutboxEvent.class));
    }

    @Test
    @DisplayName("Bẫy Idempotency nộp tiết kiệm - Trả về biên lai cũ khi trùng Idempotency Key")
    void collectDepositDuplicateIdempotency() {
        CollectSavingDepositRequest req = CollectSavingDepositRequest.builder()
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .amount(new BigDecimal("5000.00"))
                .paymentMethod(RepaymentMethod.CASH)
                .idempotencyKey("IDEM-SAV-001")
                .build();

        SavingTransaction existingTx = SavingTransaction.builder()
                .transactionId("TX-EXISTING-SAV")
                .accountNumber("SA-2026-0099")
                .customerCode("CUST-001")
                .amount(new BigDecimal("5000.00"))
                .transactionType(SavingTransactionType.DEPOSIT)
                .paymentMethod(RepaymentMethod.CASH)
                .status(RepaymentStatus.COLLECTED)
                .collectedTime(LocalDateTime.parse("2026-09-15T11:00:00"))
                .build();

        when(savingRepository.findTransactionByIdempotencyKey("IDEM-SAV-001")).thenReturn(Optional.of(existingTx));

        SavingTransactionReceiptResponse response = manageSavingsUseCase.collectDeposit(req, "USR001");

        assertNotNull(response);
        assertEquals("TX-EXISTING-SAV", response.getTransactionId());
        assertEquals("SA-2026-0099", response.getAccountNumber());

        verify(savingRepository, never()).updateAccountBalance(anyString(), any());
    }

    @Test
    @DisplayName("Khách hàng tra cứu sổ tiết kiệm - Tính toán đúng lãi dồn tích")
    void getMySavingAccounts() {
        when(savingRepository.findAccountsByCustomerCode("CUST-001")).thenReturn(List.of(activeAccount));

        List<SavingAccountResponse> accounts = manageSavingsUseCase.getMySavingAccounts("CUST-001");

        assertNotNull(accounts);
        assertEquals(1, accounts.size());
        assertEquals("SA-2026-0099", accounts.get(0).getAccountNumber());
        assertNotNull(accounts.get(0).getAccruedInterest());
    }
}
