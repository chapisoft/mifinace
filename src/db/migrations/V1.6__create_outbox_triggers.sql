-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.6__create_outbox_triggers.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Tạo 3 Database Triggers trên TD_GIAINGAN, TD_THUNO, TK_SOGD
--        Tự động ghi nhận sự kiện vào SYS_OUTBOX_EVENT phục vụ Outbox Pattern
-- ====================================================================================

-- ------------------------------------------------------------------------------------
-- 1. TRIGGER TRG_TD_GIAINGAN_OUTBOX: Bắt sự kiện giải ngân vốn vay cho khách hàng
-- ------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TRG_TD_GIAINGAN_OUTBOX]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRG_TD_GIAINGAN_OUTBOX];
GO

CREATE TRIGGER [dbo].[TRG_TD_GIAINGAN_OUTBOX]
ON [dbo].[TD_GIAINGAN]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ghi nhận sự kiện LOAN_DISBURSED vào bảng SYS_OUTBOX_EVENT
    INSERT INTO [dbo].[SYS_OUTBOX_EVENT] (
        [Aggregate_Type],
        [Aggregate_ID],
        [Event_Type],
        [Payload_JSON],
        [Status],
        [Retry_Count],
        [Max_Retries],
        [Created_Time]
    )
    SELECT 
        'LOAN',
        CAST(i.Ma_Kk AS VARCHAR(64)),
        'LOAN_DISBURSED',
        N'{"contractCode":"' + CAST(i.Ma_Kk AS NVARCHAR(64)) + N'",' +
        N'"customerId":"' + CAST(i.Ma_Khach_Hang AS NVARCHAR(32)) + N'",' +
        N'"amount":' + CAST(i.So_Tien_GN AS NVARCHAR(32)) + N',' +
        N'"currency":"MMK",' +
        N'"disbursedDate":"' + CONVERT(NVARCHAR(19), ISNULL(i.Ngay_GN, GETDATE()), 120) + N'"' +
        N'}',
        'PENDING',
        0,
        5,
        GETDATE()
    FROM INSERTED i;
END;
GO

-- ------------------------------------------------------------------------------------
-- 2. TRIGGER TRG_TD_THUNO_OUTBOX: Bắt sự kiện thu nợ / thanh toán định kỳ tại quầy
-- ------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TRG_TD_THUNO_OUTBOX]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRG_TD_THUNO_OUTBOX];
GO

CREATE TRIGGER [dbo].[TRG_TD_THUNO_OUTBOX]
ON [dbo].[TD_THUNO]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ghi nhận sự kiện PAYMENT_RECEIVED vào bảng SYS_OUTBOX_EVENT
    INSERT INTO [dbo].[SYS_OUTBOX_EVENT] (
        [Aggregate_Type],
        [Aggregate_ID],
        [Event_Type],
        [Payload_JSON],
        [Status],
        [Retry_Count],
        [Max_Retries],
        [Created_Time]
    )
    SELECT 
        'LOAN',
        CAST(i.Ma_Kk AS VARCHAR(64)),
        'PAYMENT_RECEIVED',
        N'{"contractCode":"' + CAST(i.Ma_Kk AS NVARCHAR(64)) + N'",' +
        N'"customerId":"' + CAST(i.Ma_Khach_Hang AS NVARCHAR(32)) + N'",' +
        N'"amount":' + CAST(i.So_Tien_Thu AS NVARCHAR(32)) + N',' +
        N'"periodNumber":' + CAST(ISNULL(i.Ky_Thu, 1) AS NVARCHAR(16)) + N',' +
        N'"currency":"MMK",' +
        N'"paymentDate":"' + CONVERT(NVARCHAR(19), ISNULL(i.Ngay_Thu, GETDATE()), 120) + N'"' +
        N'}',
        'PENDING',
        0,
        5,
        GETDATE()
    FROM INSERTED i;
END;
GO

-- ------------------------------------------------------------------------------------
-- 3. TRIGGER TRG_TK_SOGD_OUTBOX: Bắt sự kiện gửi/rút tiền tiết kiệm thành viên
-- ------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TRG_TK_SOGD_OUTBOX]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRG_TK_SOGD_OUTBOX];
GO

CREATE TRIGGER [dbo].[TRG_TK_SOGD_OUTBOX]
ON [dbo].[TK_SOGD]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ghi nhận sự kiện biến động số dư tiết kiệm vào bảng SYS_OUTBOX_EVENT
    INSERT INTO [dbo].[SYS_OUTBOX_EVENT] (
        [Aggregate_Type],
        [Aggregate_ID],
        [Event_Type],
        [Payload_JSON],
        [Status],
        [Retry_Count],
        [Max_Retries],
        [Created_Time]
    )
    SELECT 
        'SAVING',
        CAST(i.So_So_TK AS VARCHAR(64)),
        CASE 
            WHEN UPPER(LTRIM(RTRIM(i.Loai_GD))) = 'G' THEN 'SAVING_DEPOSITED'
            ELSE 'SAVING_WITHDRAWN'
        END,
        N'{"accountNumber":"' + CAST(i.So_So_TK AS NVARCHAR(64)) + N'",' +
        N'"customerId":"' + CAST(i.Ma_Khach_Hang AS NVARCHAR(32)) + N'",' +
        N'"transactionType":"' + CAST(i.Loai_GD AS NVARCHAR(8)) + N'",' +
        N'"amount":' + CAST(i.So_Tien_GD AS NVARCHAR(32)) + N',' +
        N'"currency":"MMK",' +
        N'"transactionDate":"' + CONVERT(NVARCHAR(19), ISNULL(i.Ngay_GD, GETDATE()), 120) + N'"' +
        N'}',
        'PENDING',
        0,
        5,
        GETDATE()
    FROM INSERTED i;
END;
GO
