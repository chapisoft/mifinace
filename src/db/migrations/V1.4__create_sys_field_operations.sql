-- ========================================================================================
-- BMF MICRO FINANCE PLATFORM - DATABASE MIGRATION SCRIPT
-- Script: V1.4__create_sys_field_operations.sql
-- Mục đích: Tạo các bảng quản lý hồ sơ vay vốn, tiết kiệm, bảo hiểm và bàn giao quỹ thực địa
-- ========================================================================================

-- 1. Bảng SYS_LOAN_APPLICATION (Hồ sơ vay vốn và thẩm định tín dụng thực địa)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_LOAN_APPLICATION]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_LOAN_APPLICATION] (
        [Application_ID] VARCHAR(64) NOT NULL,
        [Customer_Code] VARCHAR(32) NOT NULL,
        [Customer_Name] NVARCHAR(150) NOT NULL,
        [NRC_Number] VARCHAR(50) NOT NULL,
        [Group_Code] VARCHAR(32) NOT NULL,
        [Loan_Product_Code] VARCHAR(32) NOT NULL,
        [Requested_Amount] DECIMAL(18, 2) NOT NULL,
        [Term_Months] INT NOT NULL,
        [Purpose] NVARCHAR(255) NULL,
        [GPS_Latitude] DECIMAL(10, 7) NULL,
        [GPS_Longitude] DECIMAL(10, 7) NULL,
        [NRC_Front_Image_URL] VARCHAR(500) NULL,
        [NRC_Back_Image_URL] VARCHAR(500) NULL,
        [Survey_Image_URL] VARCHAR(500) NULL,
        [Signature_Image_URL] VARCHAR(500) NULL,
        [Status] VARCHAR(32) NOT NULL,
        [Credit_Score] INT NULL,
        [Created_By] VARCHAR(64) NOT NULL,
        [Created_Time] DATETIME2(3) NOT NULL CONSTRAINT DF_SYS_LOAN_APP_CREATED DEFAULT SYSUTCDATETIME(),
        [Updated_Time] DATETIME2(3) NULL,
        CONSTRAINT PK_SYS_LOAN_APPLICATION PRIMARY KEY CLUSTERED ([Application_ID])
    );

    CREATE NONCLUSTERED INDEX [IDX_SYS_LOAN_APP_CUST] ON [dbo].[SYS_LOAN_APPLICATION] ([Customer_Code], [Status]);
    CREATE NONCLUSTERED INDEX [IDX_SYS_LOAN_APP_GROUP] ON [dbo].[SYS_LOAN_APPLICATION] ([Group_Code]);
    CREATE NONCLUSTERED INDEX [IDX_SYS_LOAN_APP_NRC] ON [dbo].[SYS_LOAN_APPLICATION] ([NRC_Number]);
END;
GO

-- 2. Bảng SYS_SAVING_ACCOUNT (Tài khoản sổ tiết kiệm)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_SAVING_ACCOUNT]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_SAVING_ACCOUNT] (
        [Account_Number] VARCHAR(32) NOT NULL,
        [Customer_Code] VARCHAR(32) NOT NULL,
        [Customer_Name] NVARCHAR(150) NOT NULL,
        [Product_Type] VARCHAR(32) NOT NULL,
        [Balance] DECIMAL(18, 2) NOT NULL CONSTRAINT DF_SYS_SAVING_ACC_BAL DEFAULT 0,
        [Interest_Rate] DECIMAL(5, 2) NOT NULL,
        [Term_Months] INT NOT NULL CONSTRAINT DF_SYS_SAVING_ACC_TERM DEFAULT 0,
        [Beneficiary_Name] NVARCHAR(150) NULL,
        [Beneficiary_NRC] VARCHAR(50) NULL,
        [Status] VARCHAR(32) NOT NULL,
        [Created_By] VARCHAR(64) NOT NULL,
        [Created_Time] DATETIME2(3) NOT NULL CONSTRAINT DF_SYS_SAVING_ACC_CREATED DEFAULT SYSUTCDATETIME(),
        [Updated_Time] DATETIME2(3) NULL,
        CONSTRAINT PK_SYS_SAVING_ACCOUNT PRIMARY KEY CLUSTERED ([Account_Number])
    );

    CREATE NONCLUSTERED INDEX [IDX_SYS_SAVING_ACC_CUST] ON [dbo].[SYS_SAVING_ACCOUNT] ([Customer_Code], [Status]);
END;
GO

-- 3. Bảng SYS_SAVING_TRANSACTION (Giao dịch thu/gửi tiền tiết kiệm)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_SAVING_TRANSACTION]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_SAVING_TRANSACTION] (
        [Transaction_ID] VARCHAR(64) NOT NULL,
        [Account_Number] VARCHAR(32) NOT NULL,
        [Customer_Code] VARCHAR(32) NOT NULL,
        [Amount] DECIMAL(18, 2) NOT NULL,
        [Transaction_Type] VARCHAR(32) NOT NULL,
        [Payment_Method] VARCHAR(32) NOT NULL,
        [Collected_By] VARCHAR(64) NOT NULL,
        [Idempotency_Key] VARCHAR(64) NOT NULL,
        [Collected_Time] DATETIME2(3) NOT NULL,
        [Status] VARCHAR(32) NOT NULL,
        [Created_Time] DATETIME2(3) NOT NULL CONSTRAINT DF_SYS_SAVING_TX_CREATED DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_SYS_SAVING_TRANSACTION PRIMARY KEY CLUSTERED ([Transaction_ID]),
        CONSTRAINT UQ_SYS_SAVING_TX_IDEMPOTENCY UNIQUE ([Idempotency_Key])
    );

    CREATE NONCLUSTERED INDEX [IDX_SYS_SAVING_TX_ACC] ON [dbo].[SYS_SAVING_TRANSACTION] ([Account_Number]);
    CREATE NONCLUSTERED INDEX [IDX_SYS_SAVING_TX_COLLECTOR] ON [dbo].[SYS_SAVING_TRANSACTION] ([Collected_By], [Collected_Time]);
END;
GO

-- 4. Bảng SYS_INSURANCE_CLAIM (Hồ sơ yêu cầu bồi thường bảo hiểm tương hỗ)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_INSURANCE_CLAIM]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_INSURANCE_CLAIM] (
        [Claim_ID] VARCHAR(64) NOT NULL,
        [Customer_Code] VARCHAR(32) NOT NULL,
        [Contract_Code] VARCHAR(32) NULL,
        [Risk_Type] VARCHAR(32) NOT NULL,
        [Claim_Amount] DECIMAL(18, 2) NOT NULL,
        [Medical_Doc_URLs] NVARCHAR(MAX) NULL,
        [Village_Head_Doc_URL] VARCHAR(500) NULL,
        [Description] NVARCHAR(500) NULL,
        [Status] VARCHAR(32) NOT NULL,
        [Submitted_By] VARCHAR(64) NOT NULL,
        [Submitted_Time] DATETIME2(3) NOT NULL CONSTRAINT DF_SYS_INS_CLAIM_SUBMITTED DEFAULT SYSUTCDATETIME(),
        [Approved_Time] DATETIME2(3) NULL,
        [Approved_By] VARCHAR(64) NULL,
        CONSTRAINT PK_SYS_INSURANCE_CLAIM PRIMARY KEY CLUSTERED ([Claim_ID])
    );

    CREATE NONCLUSTERED INDEX [IDX_SYS_INS_CLAIM_CUST] ON [dbo].[SYS_INSURANCE_CLAIM] ([Customer_Code], [Status]);
END;
GO

-- 5. Bảng SYS_CASH_HANDOVER (Biên bản bàn giao quỹ tiền mặt lưu động cuối ngày)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_CASH_HANDOVER]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_CASH_HANDOVER] (
        [Handover_ID] VARCHAR(64) NOT NULL,
        [Collector_ID] VARCHAR(64) NOT NULL,
        [Handover_Date] DATE NOT NULL,
        [Total_Amount] DECIMAL(18, 2) NOT NULL,
        [Total_Transactions] INT NOT NULL,
        [QR_Payload] NVARCHAR(MAX) NOT NULL,
        [QR_Signature] VARCHAR(256) NOT NULL,
        [Status] VARCHAR(32) NOT NULL,
        [Created_Time] DATETIME2(3) NOT NULL CONSTRAINT DF_SYS_CASH_HANDOVER_CREATED DEFAULT SYSUTCDATETIME(),
        [Confirmed_By] VARCHAR(64) NULL,
        [Confirmed_Time] DATETIME2(3) NULL,
        CONSTRAINT PK_SYS_CASH_HANDOVER PRIMARY KEY CLUSTERED ([Handover_ID])
    );

    CREATE NONCLUSTERED INDEX [IDX_SYS_CASH_HANDOVER_COLLECTOR] ON [dbo].[SYS_CASH_HANDOVER] ([Collector_ID], [Handover_Date]);
END;
GO
