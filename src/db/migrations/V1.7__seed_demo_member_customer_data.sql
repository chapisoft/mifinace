-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.7__seed_demo_member_customer_data.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Khởi tạo và rà soát dữ liệu mẫu chuẩn hóa cho Khách hàng thành viên (KH_THANHVIEN),
--       Hợp đồng tín dụng (TD_HOPDONG), Lịch thu nợ (TD_LICH_THUNO), Giao dịch gạch nợ
--       (SYS_REPAYMENT_TRANSACTION) và Sổ tiết kiệm (SYS_SAVING_ACCOUNT).
-- ====================================================================================

-- 1. BẢO ĐẢM CẤU TRÚC BẢNG DANH MỤC CỤM & TỔ NẾU CHƯA TỒN TẠI
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DM_CUM]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DM_CUM] (
        [Ma_Cum]             VARCHAR(32)          NOT NULL,
        [Ten_Cum]            NVARCHAR(128)        NOT NULL,
        [Township]           NVARCHAR(64)         NOT NULL,
        [Dia_Chi]            NVARCHAR(255)        NULL,
        [Trang_Thai]         INT                  NOT NULL DEFAULT 1,
        CONSTRAINT [PK_DM_CUM] PRIMARY KEY CLUSTERED ([Ma_Cum])
    );
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DM_CUM' AND COLUMN_NAME = 'Township')
        ALTER TABLE [dbo].[DM_CUM] ADD [Township] NVARCHAR(64) NULL;
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DM_CUM' AND COLUMN_NAME = 'Dia_Chi')
        ALTER TABLE [dbo].[DM_CUM] ADD [Dia_Chi] NVARCHAR(255) NULL;
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DM_CUM' AND COLUMN_NAME = 'Trang_Thai')
        ALTER TABLE [dbo].[DM_CUM] ADD [Trang_Thai] INT NOT NULL DEFAULT 1;
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DM_TO]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DM_TO] (
        [Ma_To]              VARCHAR(32)          NOT NULL,
        [Ten_To]             NVARCHAR(128)        NOT NULL,
        [Ma_Cum]             VARCHAR(32)          NOT NULL,
        [Nhom_Truong]        NVARCHAR(128)        NULL,
        [Trang_Thai]         INT                  NOT NULL DEFAULT 1,
        CONSTRAINT [PK_DM_TO] PRIMARY KEY CLUSTERED ([Ma_To])
    );
END
GO

-- 2. BẢO ĐẢM CẤU TRÚC BẢNG KHÁCH HÀNG THÀNH VIÊN NẾU CHƯA TỒN TẠI
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KH_THANHVIEN]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[KH_THANHVIEN] (
        [Ma_ThanhVien]       VARCHAR(32)          NOT NULL,
        [Ten_ThanhVien]      NVARCHAR(128)        NOT NULL,
        [So_NRC]             VARCHAR(32)          NOT NULL,
        [So_DienThoai]       VARCHAR(20)          NULL,
        [Ma_PIN]             VARCHAR(256)         NULL,
        [Ma_To]              VARCHAR(32)          NOT NULL,
        [Ma_Cum]             VARCHAR(32)          NOT NULL,
        [Township]           NVARCHAR(64)         NULL,
        [Trang_Thai]         INT                  NOT NULL DEFAULT 1,
        [Ngay_GiaNhap]       DATETIME             NOT NULL DEFAULT GETDATE(),
        [Ngay_CapNhat]       DATETIME             NULL,
        CONSTRAINT [PK_KH_THANHVIEN] PRIMARY KEY CLUSTERED ([Ma_ThanhVien]),
        CONSTRAINT [UQ_KH_THANHVIEN_NRC] UNIQUE ([So_NRC])
    );
END
GO

-- 3. BẢO ĐẢM CẤU TRÚC BẢNG HỢP ĐỒNG TÍN DỤNG & LỊCH THU NỢ
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TD_HOPDONG]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TD_HOPDONG] (
        [Ma_HopDong]         VARCHAR(64)          NOT NULL,
        [Ma_ThanhVien]       VARCHAR(32)          NOT NULL,
        [Ma_To]              VARCHAR(32)          NOT NULL,
        [Goi_Vay]            VARCHAR(32)          NOT NULL DEFAULT 'MICRO_BIZ_01',
        [So_Tien_Vay]        DECIMAL(18,2)        NOT NULL,
        [Lai_Suat_Nam]       DECIMAL(5,2)         NOT NULL DEFAULT 28.00,
        [Ngay_GiaiNgan]      DATETIME             NOT NULL,
        [Ngay_DaoHan]        DATETIME             NOT NULL,
        [So_Ky_Vay]          INT                  NOT NULL DEFAULT 12,
        [Trang_Thai]         VARCHAR(16)          NOT NULL DEFAULT 'ACTIVE',
        CONSTRAINT [PK_TD_HOPDONG] PRIMARY KEY CLUSTERED ([Ma_HopDong])
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TD_LICH_THUNO]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TD_LICH_THUNO] (
        [Ma_HopDong]         VARCHAR(64)          NOT NULL,
        [Ky_Thu]             INT                  NOT NULL,
        [Tien_Goc]           DECIMAL(18,2)        NOT NULL,
        [Tien_Lai]           DECIMAL(18,2)        NOT NULL,
        [Phi_BaoHiem]        DECIMAL(18,2)        NOT NULL DEFAULT 0.0,
        [TietKiem_BatBuoc]   DECIMAL(18,2)        NOT NULL DEFAULT 0.0,
        [Tong_Tien]          DECIMAL(18,2)        NOT NULL,
        [Ngay_DenHan]        DATE                 NOT NULL,
        [Trang_Thai]         VARCHAR(16)          NOT NULL DEFAULT 'PENDING',
        CONSTRAINT [PK_TD_LICH_THUNO] PRIMARY KEY CLUSTERED ([Ma_HopDong], [Ky_Thu])
    );
END
GO

-- ====================================================================================
-- SEED DỮ LIỆU ĐỊNH DANH KHÁCH HÀNG & RÀNG BUỘC TOÀN VẸN
-- ====================================================================================

-- A. Cụm và Tổ vay vốn mẫu
IF NOT EXISTS (SELECT 1 FROM [dbo].[DM_CUM] WHERE [Ma_Cum] = 'CTR-YGN-01')
BEGIN
    INSERT INTO [dbo].[DM_CUM] (
        [ID_DVI], [ID_KVUC], [MA_CUM], [TEN_CUM], [TEN_TAT],
        [TTHAI_BGHI], [TTHAI_NVU], [MA_DVI_QLY], [MA_DVI_TAO],
        [NGAY_NHAP], [NGUOI_NHAP], [Township], [Dia_Chi], [Trang_Thai]
    )
    VALUES (
        5, 3, 'CTR-YGN-01', N'Dagon Central Center', N'Dagon Center',
        'SDU', 'DDU', '0001', '000100',
        '20260101', 'SYSTEM', N'Dagon Township', N'No. 45, Bogyoke Road, Dagon', 1
    );
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[DM_TO] WHERE [Ma_To] = 'GRP-YGN-01')
BEGIN
    INSERT INTO [dbo].[DM_TO] ([Ma_To], [Ten_To], [Ma_Cum], [Nhom_Truong], [Trang_Thai])
    VALUES ('GRP-YGN-01', N'Solidarity Group 01', 'CTR-YGN-01', N'Daw Khin Myint', 1);
END
GO

-- B. Khách hàng thành viên CUST-001 (Daw Khin Myint)
-- Mã PIN 123456 được băm BCrypt chuẩn Spring Security ($2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO)
IF NOT EXISTS (SELECT 1 FROM [dbo].[KH_THANHVIEN] WHERE [Ma_ThanhVien] = 'CUST-001')
BEGIN
    INSERT INTO [dbo].[KH_THANHVIEN] (
        [Ma_ThanhVien], [Ten_ThanhVien], [So_NRC], [So_DienThoai], [Ma_PIN],
        [Ma_To], [Ma_Cum], [Township], [Trang_Thai], [Ngay_GiaNhap]
    )
    VALUES (
        'CUST-001', N'Daw Khin Myint', '12/DAGAMA(N)045612', '09123456789',
        '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        'GRP-YGN-01', 'CTR-YGN-01', N'Dagon Township', 1, DATEADD(MONTH, -8, GETDATE())
    );
END
ELSE
BEGIN
    UPDATE [dbo].[KH_THANHVIEN]
    SET [Ten_ThanhVien] = N'Daw Khin Myint',
        [So_NRC] = '12/DAGAMA(N)045612',
        [So_DienThoai] = '09123456789',
        [Ma_PIN] = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        [Ma_To] = 'GRP-YGN-01',
        [Ma_Cum] = 'CTR-YGN-01',
        [Township] = N'Dagon Township',
        [Trang_Thai] = 1
    WHERE [Ma_ThanhVien] = 'CUST-001';
END
GO

-- C. Hợp đồng tín dụng HD-2026-001 thuộc Khách hàng CUST-001
IF NOT EXISTS (SELECT 1 FROM [dbo].[TD_HOPDONG] WHERE [Ma_HopDong] = 'HD-2026-001')
BEGIN
    INSERT INTO [dbo].[TD_HOPDONG] (
        [Ma_HopDong], [Ma_ThanhVien], [Ma_To], [Goi_Vay], [So_Tien_Vay],
        [Lai_Suat_Nam], [Ngay_GiaiNgan], [Ngay_DaoHan], [So_Ky_Vay], [Trang_Thai]
    )
    VALUES (
        'HD-2026-001', 'CUST-001', 'GRP-YGN-01', 'MICRO_BIZ_01', 1500000.00,
        28.00, DATEADD(MONTH, -7, GETDATE()), DATEADD(MONTH, 5, GETDATE()), 12, 'ACTIVE'
    );
END
GO

-- D. Lịch thu nợ 12 kỳ của HD-2026-001
-- Kỳ 1..7: Đã thanh toán (SETTLED)
-- Kỳ 8: Đến hạn hôm nay (DUE_TODAY)
-- Kỳ 9..12: Sắp tới (PENDING)
DECLARE @Period INT = 1;
WHILE @Period <= 12
BEGIN
    DECLARE @DueDate DATE = CAST(DATEADD(MONTH, @Period - 7, GETDATE()) AS DATE);
    DECLARE @Status VARCHAR(16) = CASE 
        WHEN @Period < 7 THEN 'SETTLED'
        WHEN @Period = 7 THEN 'SETTLED'
        WHEN @Period = 8 THEN 'DUE_TODAY'
        ELSE 'PENDING'
    END;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[TD_LICH_THUNO] WHERE [Ma_HopDong] = 'HD-2026-001' AND [Ky_Thu] = @Period)
    BEGIN
        INSERT INTO [dbo].[TD_LICH_THUNO] (
            [Ma_HopDong], [Ky_Thu], [Tien_Goc], [Tien_Lai], [Phi_BaoHiem],
            [TietKiem_BatBuoc], [Tong_Tien], [Ngay_DenHan], [Trang_Thai]
        )
        VALUES (
            'HD-2026-001', @Period, 50000.00, 6250.00, 1000.00,
            2000.00, 59250.00, @DueDate, @Status
        );
    END
    ELSE
    BEGIN
        UPDATE [dbo].[TD_LICH_THUNO]
        SET [Tien_Goc] = 50000.00,
            [Tien_Lai] = 6250.00,
            [Phi_BaoHiem] = 1000.00,
            [TietKiem_BatBuoc] = 2000.00,
            [Tong_Tien] = 59250.00,
            [Ngay_DenHan] = @DueDate,
            [Trang_Thai] = @Status
        WHERE [Ma_HopDong] = 'HD-2026-001' AND [Ky_Thu] = @Period;
    END

    SET @Period = @Period + 1;
END
GO

-- E. Giao dịch thanh toán thực tế trong bảng SYS_REPAYMENT_TRANSACTION
-- Khách hàng CUST-001 đã gạch nợ thành công 7 kỳ đầu
MERGE dbo.SYS_REPAYMENT_TRANSACTION AS target
USING (VALUES
    ('TX-123456', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 1, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-SEED-001', 'BMF_OFFICER_01', DATEADD(MONTH, -6, GETDATE()), 'SETTLED', N'Field collection period 1 at village center'),
    ('REC-2026-001', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 2, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-SEED-002', 'BMF_OFFICER_01', DATEADD(MONTH, -5, GETDATE()), 'SETTLED', N'Field collection period 2 at village center'),
    ('REC-2026-002', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 3, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'KBZ_PAY', 'IDEM-SEED-003', 'BMF_OFFICER_01', DATEADD(MONTH, -4, GETDATE()), 'SETTLED', N'Monthly installment period 3 via KBZPay'),
    ('REC-2026-003', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 4, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'WAVE_PAY', 'IDEM-SEED-004', 'BMF_OFFICER_01', DATEADD(MONTH, -3, GETDATE()), 'SETTLED', N'Monthly installment period 4 via WavePay'),
    ('REC-2026-004', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 5, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-SEED-005', 'BMF_OFFICER_01', DATEADD(MONTH, -2, GETDATE()), 'SETTLED', N'Over-the-counter collection period 5 at center'),
    ('REC-2026-005', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 6, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-SEED-006', 'BMF_OFFICER_01', DATEADD(MONTH, -1, GETDATE()), 'SETTLED', N'Over-the-counter collection period 6 at center'),
    ('REC-2026-006', 'HD-2026-001', 'CUST-001', N'Daw Khin Myint', 'GRP-YGN-01', 7, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'MMQR', 'IDEM-SEED-007', 'BMF_OFFICER_01', DATEADD(DAY, -1, GETDATE()), 'SETTLED', N'Digital repayment period 7 via MMQR scan')
) AS source (
    Transaction_ID, Contract_Code, Customer_Code, Customer_Name, Group_Code,
    Period_Number, Principal_Amount, Interest_Amount, Insurance_Fee, Compulsory_Saving,
    Penalty_Amount, Total_Amount, Payment_Method, Idempotency_Key, Collected_By,
    Collected_Time, Status, Notes
)
ON (target.Transaction_ID = source.Transaction_ID)
WHEN MATCHED THEN
    UPDATE SET
        Contract_Code = source.Contract_Code,
        Customer_Code = source.Customer_Code,
        Customer_Name = source.Customer_Name,
        Total_Amount = source.Total_Amount,
        Payment_Method = source.Payment_Method,
        Status = source.Status,
        Notes = source.Notes
WHEN NOT MATCHED THEN
    INSERT (Transaction_ID, Contract_Code, Customer_Code, Customer_Name, Group_Code,
            Period_Number, Principal_Amount, Interest_Amount, Insurance_Fee, Compulsory_Saving,
            Penalty_Amount, Total_Amount, Payment_Method, Idempotency_Key, Collected_By,
            Collected_Time, Status, Notes)
    VALUES (source.Transaction_ID, source.Contract_Code, source.Customer_Code, source.Customer_Name, source.Group_Code,
            source.Period_Number, source.Principal_Amount, source.Interest_Amount, source.Insurance_Fee, source.Compulsory_Saving,
            source.Penalty_Amount, source.Total_Amount, source.Payment_Method, source.Idempotency_Key, source.Collected_By,
            source.Collected_Time, source.Status, source.Notes);
GO

-- F. Sổ tiết kiệm của CUST-001 trong SYS_SAVING_ACCOUNT
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SYS_SAVING_ACCOUNT' AND COLUMN_NAME = 'Accrued_Interest')
BEGIN
    ALTER TABLE [dbo].[SYS_SAVING_ACCOUNT] ADD [Accrued_Interest] DECIMAL(18,2) NOT NULL DEFAULT 0.0;
END
GO

MERGE dbo.SYS_SAVING_ACCOUNT AS target
USING (VALUES
    ('SA-2026-0099', 'CUST-001', N'Daw Khin Myint', 'COMPULSORY', 120000.00, 8.00, 4800.00, 12, 'ACTIVE', 'SYSTEM', DATEADD(MONTH, -7, GETDATE())),
    ('SA-2026-0100', 'CUST-001', N'Daw Khin Myint', 'VOLUNTARY', 250000.00, 10.00, 12500.00, 0, 'ACTIVE', 'SYSTEM', DATEADD(MONTH, -5, GETDATE()))
) AS source (
    Account_Number, Customer_Code, Customer_Name, Product_Type, Balance,
    Interest_Rate, Accrued_Interest, Term_Months, Status, Created_By, Created_Time
)
ON (target.Account_Number = source.Account_Number)
WHEN MATCHED THEN
    UPDATE SET
        Customer_Code = source.Customer_Code,
        Customer_Name = source.Customer_Name,
        Balance = source.Balance,
        Accrued_Interest = source.Accrued_Interest,
        Status = source.Status
WHEN NOT MATCHED THEN
    INSERT (Account_Number, Customer_Code, Customer_Name, Product_Type, Balance,
            Interest_Rate, Accrued_Interest, Term_Months, Status, Created_By, Created_Time)
    VALUES (source.Account_Number, source.Customer_Code, source.Customer_Name, source.Product_Type, source.Balance,
            source.Interest_Rate, source.Accrued_Interest, source.Term_Months, source.Status, source.Created_By, source.Created_Time);
GO
