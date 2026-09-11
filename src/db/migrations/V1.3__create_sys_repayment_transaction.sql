-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.3__create_sys_repayment_transaction.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Tạo bảng SYS_REPAYMENT_TRANSACTION lưu vết các giao dịch gạch nợ tín dụng
-- ====================================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_REPAYMENT_TRANSACTION]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_REPAYMENT_TRANSACTION] (
        [Transaction_ID]     VARCHAR(64)          NOT NULL,              -- Mã giao dịch duy nhất (Khóa chính)
        [Contract_Code]      VARCHAR(64)          NOT NULL,              -- Mã hợp đồng tín dụng
        [Customer_Code]      VARCHAR(32)          NOT NULL,              -- Mã khách hàng thành viên
        [Customer_Name]      NVARCHAR(128)        NULL,                  -- Họ và tên khách hàng
        [Group_Code]         VARCHAR(32)          NULL,                  -- Mã Cụm/Tổ
        [Period_Number]      INT                  NOT NULL,              -- Kỳ thu nợ
        [Principal_Amount]   DECIMAL(18,2)        NULL,                  -- Tiền gốc đã thu (MMK)
        [Interest_Amount]    DECIMAL(18,2)        NULL,                  -- Tiền lãi đã thu (MMK)
        [Insurance_Fee]      DECIMAL(18,2)        NULL,                  -- Phí bảo hiểm vi mô (MMK)
        [Compulsory_Saving]  DECIMAL(18,2)        NULL,                  -- Tiết kiệm bắt buộc (MMK)
        [Penalty_Amount]     DECIMAL(18,2)        NULL,                  -- Tiền phạt chậm trả (MMK)
        [Total_Amount]       DECIMAL(18,2)        NOT NULL,              -- Tổng tiền thu thực tế (MMK)
        [Payment_Method]     VARCHAR(32)          NOT NULL,              -- Phương thức: 'CASH', 'WAVE_PAY', 'KBZ_PAY', 'BANK_TRANSFER'
        [Idempotency_Key]    VARCHAR(64)          NOT NULL,              -- Khóa chống trùng lặp từ Mobile Client
        [Collected_By]       VARCHAR(32)          NOT NULL,              -- Cán bộ tín dụng thực hiện thu
        [Collected_Time]     DATETIME             NOT NULL,              -- Thời điểm thu tiền tại thực địa
        [Synced_Time]        DATETIME             NOT NULL DEFAULT GETDATE(), -- Thời điểm đồng bộ lên Gateway
        [Status]             VARCHAR(16)          NOT NULL DEFAULT 'COLLECTED', -- Trạng thái: 'COLLECTED', 'SETTLED', 'FAILED'
        [Notes]              NVARCHAR(255)        NULL,                  -- Ghi chú giao dịch
        CONSTRAINT [PK_SYS_REPAYMENT_TRANSACTION] PRIMARY KEY CLUSTERED ([Transaction_ID]),
        CONSTRAINT [UQ_SYS_REPAYMENT_IDEMPOTENCY] UNIQUE ([Idempotency_Key])
    );

    -- Chỉ mục tối ưu tra cứu lịch sử giao dịch theo hợp đồng và kỳ nợ
    CREATE NONCLUSTERED INDEX [IDX_SYS_REPAYMENT_CONTRACT]
    ON [dbo].[SYS_REPAYMENT_TRANSACTION] ([Contract_Code], [Period_Number]);

    -- Chỉ mục tra cứu danh sách thu tiền theo cán bộ và ngày thu
    CREATE NONCLUSTERED INDEX [IDX_SYS_REPAYMENT_COLLECTOR]
    ON [dbo].[SYS_REPAYMENT_TRANSACTION] ([Collected_By], [Collected_Time]);
END
GO
