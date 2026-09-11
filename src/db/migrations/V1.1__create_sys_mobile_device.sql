-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.1__create_sys_mobile_device.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Tạo bảng SYS_MOBILE_DEVICE quản lý thiết bị di động của Cán bộ và Khách hàng
-- ====================================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_MOBILE_DEVICE]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_MOBILE_DEVICE] (
        [Device_ID]          VARCHAR(64)       NOT NULL,                 -- Mã định danh phần cứng (Hardware UUID)
        [User_ID]            VARCHAR(32)       NOT NULL,                 -- Mã cán bộ (HT_NGUOIDUNG) hoặc Mã khách hàng (KH_THANHVIEN)
        [User_Type]          VARCHAR(16)       NOT NULL,                 -- Loại người dùng: 'AGENT' hoặc 'CUSTOMER'
        [Platform]           VARCHAR(16)       NOT NULL,                 -- Nền tảng: 'ANDROID' hoặc 'IOS'
        [Device_Name]        NVARCHAR(128)     NULL,                     -- Tên thiết bị (ví dụ: 'Samsung Galaxy A15', 'iPhone 13')
        [OS_Version]         VARCHAR(32)       NULL,                     -- Phiên bản hệ điều hành (ví dụ: 'Android 14', 'iOS 17.5')
        [App_Version]        VARCHAR(16)       NOT NULL,                 -- Phiên bản ứng dụng (ví dụ: '1.0.0')
        [Push_Token]         VARCHAR(256)      NULL,                     -- Firebase FCM Token hoặc Apple APNs Token
        [Public_Key]         VARCHAR(512)      NULL,                     -- Khóa công khai của thiết bị lưu trữ trên Keystore/Keychain
        [Is_Active]          BIT               NOT NULL DEFAULT 1,       -- Trạng thái kích hoạt: 1 (Hoạt động), 0 (Bị khóa)
        [Last_Active_Time]   DATETIME          NOT NULL DEFAULT GETDATE(),-- Thời gian tương tác gần nhất
        [Created_Time]       DATETIME          NOT NULL DEFAULT GETDATE(),-- Thời gian đăng ký thiết bị
        [Updated_Time]       DATETIME          NOT NULL DEFAULT GETDATE(),-- Thời gian cập nhật thông tin
        CONSTRAINT [PK_SYS_MOBILE_DEVICE] PRIMARY KEY CLUSTERED ([Device_ID], [User_ID])
    );

    -- Tạo chỉ mục tìm kiếm theo User_ID và User_Type
    CREATE NONCLUSTERED INDEX [IDX_SYS_MOBILE_DEVICE_USER]
    ON [dbo].[SYS_MOBILE_DEVICE] ([User_ID], [User_Type], [Is_Active])
    INCLUDE ([Device_ID], [Push_Token], [Platform], [Last_Active_Time]);

    -- Tạo chỉ mục tối ưu cho việc quét Push_Token gửi thông báo hàng loạt
    CREATE NONCLUSTERED INDEX [IDX_SYS_MOBILE_DEVICE_PUSH]
    ON [dbo].[SYS_MOBILE_DEVICE] ([Push_Token])
    WHERE [Is_Active] = 1 AND [Push_Token] IS NOT NULL;
END
GO
