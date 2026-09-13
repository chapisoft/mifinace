-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.8__create_sys_app_user_and_activation_flow.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Tạo bảng SYS_APP_USER quản lý tài khoản ứng dụng Mobile App, ràng buộc khóa ngoại
--       với bảng hồ sơ thành viên KH_THANHVIEN và bảng người dùng hệ thống HT_NSD.
--       Hỗ trợ luồng kiểm tra tài khoản, kích hoạt lần đầu qua OTP và quên mã PIN.
-- ====================================================================================

-- 1. BẢO ĐẢM BẢNG HT_NSD CÓ DỮ LIỆU CÁN BỘ TÍN DỤNG MẪU NẾU CHƯA CÓ
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HT_NSD]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[HT_NSD] (
        [ID]                 INT IDENTITY(1,1)    NOT NULL,
        [MA_NSD]             VARCHAR(30)          NOT NULL,
        [MA_DANG_NHAP]       VARCHAR(30)          NOT NULL,
        [PHAN_LOAI_NSD]      VARCHAR(30)          NOT NULL DEFAULT 'AGENT',
        [MAT_KHAU]           VARCHAR(128)         NOT NULL,
        [MA_HSO]             VARCHAR(30)          NULL,
        [TEN_GOI]            NVARCHAR(255)        NULL,
        [TEN_HO_DEM]         NVARCHAR(255)        NULL,
        [TEN_DAY_DU]         NVARCHAR(255)        NOT NULL,
        [EMAIL]              VARCHAR(255)         NULL,
        [DIEN_THOAI]         VARCHAR(20)          NULL,
        [NGAY_SINH]          VARCHAR(8)           NULL,
        [GIOI_TINH]          VARCHAR(10)          NULL,
        [TDOI_MKHAU]         VARCHAR(30)          NOT NULL DEFAULT '0',
        [NGAY_TAO]           VARCHAR(8)           NOT NULL DEFAULT CONVERT(VARCHAR(8), GETDATE(), 112),
        [NGAY_HIEU_LUC]      VARCHAR(8)           NOT NULL DEFAULT CONVERT(VARCHAR(8), GETDATE(), 112),
        [NGAY_HET_HAN]       VARCHAR(8)           NULL,
        [TGIAN_DOI_MKHAU]    INT                  NULL,
        [TGIAN_DOI_DVI_TINH] VARCHAR(30)          NULL,
        [NGAY_DOI_MKHAU]     VARCHAR(8)           NULL,
        [NGUON_TAO_DL]       VARCHAR(30)          NOT NULL DEFAULT 'CORE',
        [TINH_TRANG]         VARCHAR(30)          NOT NULL DEFAULT 'ACTIVE',
        [HAN_CHE_TRUY_CAP]   VARCHAR(5)           NULL DEFAULT '0',
        [TTHAI_BGHI]         VARCHAR(30)          NOT NULL DEFAULT 'ACTIVE',
        [TTHAI_NVU]          VARCHAR(30)          NOT NULL DEFAULT 'APPROVED',
        [MA_DVI_QLY]         VARCHAR(12)          NOT NULL DEFAULT 'BR-YGN-01',
        [MA_DVI_TAO]         VARCHAR(12)          NOT NULL DEFAULT 'BR-YGN-01',
        [NGAY_NHAP]          VARCHAR(8)           NOT NULL DEFAULT CONVERT(VARCHAR(8), GETDATE(), 112),
        [NGUOI_NHAP]         VARCHAR(30)          NOT NULL DEFAULT 'SYSTEM',
        [NGAY_CNHAT]         VARCHAR(8)           NULL,
        [NGUOI_CNHAT]        VARCHAR(30)          NULL,
        [TTHAI_LY_DO]        NVARCHAR(255)        NULL,
        CONSTRAINT [PK_HT_NSD] PRIMARY KEY CLUSTERED ([MA_NSD])
    );
END
GO

-- Nạp cán bộ mẫu OFFICER-01 / AGENT_YGN_001 nếu chưa có
IF NOT EXISTS (SELECT 1 FROM [dbo].[HT_NSD] WHERE [MA_DANG_NHAP] = 'OFFICER-01' OR [MA_NSD] = 'AGENT_YGN_001')
BEGIN
    INSERT INTO [dbo].[HT_NSD] (
        [MA_NSD], [MA_DANG_NHAP], [PHAN_LOAI_NSD], [MAT_KHAU],
        [TEN_DAY_DU], [EMAIL], [DIEN_THOAI], [TINH_TRANG],
        [TDOI_MKHAU], [NGAY_TAO], [NGAY_HIEU_LUC], [NGUON_TAO_DL],
        [TTHAI_BGHI], [TTHAI_NVU], [MA_DVI_QLY], [MA_DVI_TAO],
        [NGAY_NHAP], [NGUOI_NHAP]
    ) VALUES (
        'AGENT_YGN_001', 'OFFICER-01', 'AGENT',
        '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', -- 123456
        N'U Aung Kyaw', 'aung.kyaw@bmfina.com.mm', '09450012345', 'ACTIVE',
        '0', '20260101', '20260101', 'CORE',
        'ACTIVE', 'APPROVED', 'BR-YGN-01', 'BR-YGN-01',
        '20260101', 'SYSTEM'
    );
END
GO

-- 2. TẠO BẢNG QUẢN LÝ TÀI KHOẢN ỨNG DỤNG: SYS_APP_USER
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_APP_USER]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_APP_USER] (
        [User_Id]              VARCHAR(64)          NOT NULL,
        [User_Type]            VARCHAR(16)          NOT NULL, -- 'CUSTOMER' hoặc 'AGENT'
        [Business_Id]          VARCHAR(32)          NOT NULL, -- Mã thành viên (KH_THANHVIEN) hoặc Mã cán bộ (HT_NSD)
        [Identifier_Key]       VARCHAR(64)          NOT NULL, -- Số điện thoại hoặc Số NRC
        [Phone_Number]         VARCHAR(20)          NULL,
        [Nrc_Number]           VARCHAR(32)          NULL,
        [Full_Name]            NVARCHAR(128)        NOT NULL,
        [Pin_Hash]             VARCHAR(256)         NULL,     -- BCrypt băm 6 số
        [Password_Hash]        VARCHAR(256)         NULL,
        [Is_Activated]         INT                  NOT NULL DEFAULT 0, -- 0: Chưa kích hoạt, 1: Đã kích hoạt
        [Activated_Time]       DATETIME             NULL,
        [Biometric_Enabled]    INT                  NOT NULL DEFAULT 0,
        [Status]               VARCHAR(16)          NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, LOCKED, BLOCKED
        [Failed_Pin_Attempts]  INT                  NOT NULL DEFAULT 0,
        [Pin_Locked_Until]     DATETIME             NULL,
        [Last_Login_Time]      DATETIME             NULL,
        [Created_Time]         DATETIME             NOT NULL DEFAULT GETDATE(),
        [Updated_Time]         DATETIME             NULL,
        CONSTRAINT [PK_SYS_APP_USER] PRIMARY KEY CLUSTERED ([User_Id]),
        CONSTRAINT [UQ_SYS_APP_USER_IDENTIFIER] UNIQUE ([User_Type], [Identifier_Key])
    );

    CREATE NONCLUSTERED INDEX [IX_SYS_APP_USER_BUSINESS] ON [dbo].[SYS_APP_USER] ([Business_Id], [User_Type]);
    CREATE NONCLUSTERED INDEX [IX_SYS_APP_USER_PHONE] ON [dbo].[SYS_APP_USER] ([Phone_Number]);
    CREATE NONCLUSTERED INDEX [IX_SYS_APP_USER_NRC] ON [dbo].[SYS_APP_USER] ([Nrc_Number]);
END
GO

-- 3. NẠP KHÁCH HÀNG THÀNH VIÊN MẪU KHÁC ĐỂ TEST LUỒNG CHƯA KÍCH HOẠT (CUST-002)
IF NOT EXISTS (SELECT 1 FROM [dbo].[KH_THANHVIEN] WHERE [Ma_ThanhVien] = 'CUST-002')
BEGIN
    INSERT INTO [dbo].[KH_THANHVIEN] (
        [Ma_ThanhVien], [Ten_ThanhVien], [So_NRC], [So_DienThoai],
        [Ma_PIN], [Ma_To], [Ma_Cum], [Township], [Trang_Thai], [Ngay_GiaNhap]
    ) VALUES (
        'CUST-002', N'U Thant Zin', '12/DAGAMA(N)078901', '09450098765',
        NULL, -- Chưa thiết lập PIN trên App
        'GRP-YGN-01', 'CTR-YGN-01', N'Dagon Township', 1, GETDATE()
    );
END
GO

-- 4. ĐỒNG BỘ DỮ LIỆU TÀI KHOẢN APP SYS_APP_USER MẪU
-- 4.1. Khách hàng CUST-001 (Đã kích hoạt app)
IF NOT EXISTS (SELECT 1 FROM [dbo].[SYS_APP_USER] WHERE [Business_Id] = 'CUST-001' AND [User_Type] = 'CUSTOMER')
BEGIN
    INSERT INTO [dbo].[SYS_APP_USER] (
        [User_Id], [User_Type], [Business_Id], [Identifier_Key],
        [Phone_Number], [Nrc_Number], [Full_Name], [Pin_Hash],
        [Is_Activated], [Activated_Time], [Biometric_Enabled], [Status],
        [Created_Time]
    ) VALUES (
        'APP-CUST-001', 'CUSTOMER', 'CUST-001', '12/DAGAMA(N)045612',
        '09450012345', '12/DAGAMA(N)045612', N'Daw Khin Myint',
        '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', -- 123456
        1, GETDATE(), 1, 'ACTIVE', GETDATE()
    );
END
GO

-- 4.2. Khách hàng CUST-002 (Chưa kích hoạt app - Sẵn sàng test luồng kích hoạt qua OTP)
IF NOT EXISTS (SELECT 1 FROM [dbo].[SYS_APP_USER] WHERE [Business_Id] = 'CUST-002' AND [User_Type] = 'CUSTOMER')
BEGIN
    INSERT INTO [dbo].[SYS_APP_USER] (
        [User_Id], [User_Type], [Business_Id], [Identifier_Key],
        [Phone_Number], [Nrc_Number], [Full_Name], [Pin_Hash],
        [Is_Activated], [Activated_Time], [Biometric_Enabled], [Status],
        [Created_Time]
    ) VALUES (
        'APP-CUST-002', 'CUSTOMER', 'CUST-002', '12/DAGAMA(N)078901',
        '09450098765', '12/DAGAMA(N)078901', N'U Thant Zin',
        NULL, -- Chưa có PIN
        0, NULL, 0, 'ACTIVE', GETDATE()
    );
END
GO

-- 4.3. Cán bộ tín dụng AGENT_YGN_001 (Đã kích hoạt app)
IF NOT EXISTS (SELECT 1 FROM [dbo].[SYS_APP_USER] WHERE [Business_Id] = 'AGENT_YGN_001' AND [User_Type] = 'AGENT')
BEGIN
    INSERT INTO [dbo].[SYS_APP_USER] (
        [User_Id], [User_Type], [Business_Id], [Identifier_Key],
        [Phone_Number], [Nrc_Number], [Full_Name], [Pin_Hash],
        [Password_Hash], [Is_Activated], [Activated_Time], [Biometric_Enabled], [Status],
        [Created_Time]
    ) VALUES (
        'APP-AGT-001', 'AGENT', 'AGENT_YGN_001', 'OFFICER-01',
        '09450012345', NULL, N'U Aung Kyaw',
        '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', -- 123456
        '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        1, GETDATE(), 1, 'ACTIVE', GETDATE()
    );
END
GO
