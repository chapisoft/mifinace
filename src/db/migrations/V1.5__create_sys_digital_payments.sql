-- =========================================================================================
-- Migration: V1.5__create_sys_digital_payments.sql
-- Mục đích: Quản lý Yêu cầu Thanh toán Số (MMQR EMVCo CBM) và Nhật ký Webhook Ví điện tử
-- Hệ thống: Core Microfinance BMF Myanmar (SQL Server 2017)
-- =========================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SYS_PAYMENT_ORDER')
BEGIN
    CREATE TABLE SYS_PAYMENT_ORDER (
        Id BIGINT IDENTITY(1,1) NOT NULL,
        Order_No NVARCHAR(64) NOT NULL,
        Loan_Code NVARCHAR(50) NOT NULL,
        Schedule_Id BIGINT NOT NULL,
        Amount DECIMAL(18,2) NOT NULL,
        Currency NVARCHAR(10) NOT NULL,
        Provider NVARCHAR(30) NOT NULL,
        Status NVARCHAR(30) NOT NULL,
        Mmqr_Payload NVARCHAR(MAX) NULL,
        Partner_Ref_No NVARCHAR(100) NULL,
        Expired_Time DATETIME2 NOT NULL,
        Created_Time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        Updated_Time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        Settled_Time DATETIME2 NULL,

        CONSTRAINT PK_SYS_PAYMENT_ORDER PRIMARY KEY CLUSTERED (Id ASC),
        CONSTRAINT UQ_SYS_PAYMENT_ORDER_NO UNIQUE (Order_No)
    );

    CREATE NONCLUSTERED INDEX IDX_PAYMENT_ORDER_STATUS
        ON SYS_PAYMENT_ORDER (Status, Expired_Time)
        INCLUDE (Order_No, Loan_Code, Amount, Provider);

    CREATE NONCLUSTERED INDEX IDX_PAYMENT_ORDER_LOAN
        ON SYS_PAYMENT_ORDER (Loan_Code, Status);

    PRINT 'Created table SYS_PAYMENT_ORDER and indexes successfully.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SYS_PAYMENT_WEBHOOK_LOG')
BEGIN
    CREATE TABLE SYS_PAYMENT_WEBHOOK_LOG (
        Id BIGINT IDENTITY(1,1) NOT NULL,
        Provider NVARCHAR(30) NOT NULL,
        Order_No NVARCHAR(64) NULL,
        Request_Payload NVARCHAR(MAX) NOT NULL,
        Response_Payload NVARCHAR(MAX) NULL,
        Signature NVARCHAR(255) NULL,
        Status NVARCHAR(30) NOT NULL,
        Trace_Id NVARCHAR(64) NOT NULL,
        Created_Time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_SYS_PAYMENT_WEBHOOK_LOG PRIMARY KEY CLUSTERED (Id ASC)
    );

    CREATE NONCLUSTERED INDEX IDX_WEBHOOK_LOG_ORDER
        ON SYS_PAYMENT_WEBHOOK_LOG (Order_No, Provider, Status);

    CREATE NONCLUSTERED INDEX IDX_WEBHOOK_LOG_TRACE
        ON SYS_PAYMENT_WEBHOOK_LOG (Trace_Id);

    PRINT 'Created table SYS_PAYMENT_WEBHOOK_LOG and indexes successfully.';
END
GO
