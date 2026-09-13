-- ====================================================================================
-- MIGRATION: V1.10__sync_real_erp_customers_and_standardize_app_users.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MỤC TIÊU:
-- 1. Nới lỏng ràng buộc cột trong KH_THANHVIEN để đồng bộ đầy đủ 4,478 thành viên từ KH_KHANG_HSO.
-- 2. Đồng bộ 100% hồ sơ thành viên thực tế từ bảng KH_KHANG_HSO sang KH_THANHVIEN.
-- 3. Ràng buộc khóa ngoại FK_SYS_APP_USER_KH_THANHVIEN giữa SYS_APP_USER(Business_Id) và KH_THANHVIEN(Ma_ThanhVien).
-- 4. Thiết lập tài khoản mẫu đối ứng 100% với dữ liệu Core Banking thật:
--    - Agent Trưởng nhóm đã kích hoạt: 2163896 (KYAW SAN MIN, Trưởng nhóm 000100330401) - PIN 123456
--    - Agent Trưởng nhóm chưa kích hoạt: 2163980 (KHINE SHWE SIN, Trưởng nhóm 000100230201) - Test luồng kích hoạt
--    - Khách hàng đã kích hoạt: 2150001 (AUNG THIHA TUN, NRC 12/BAHANA(N)097503) - PIN 123456
--    - Khách hàng chưa kích hoạt: 2150002 (TIN MIN HTUT, NRC 12/PAZATA(N)000534, SĐT 09448034049) - Test luồng kích hoạt
-- ====================================================================================

-- 1. Nới lỏng nullability các trường phụ trong KH_THANHVIEN
ALTER TABLE dbo.KH_THANHVIEN ALTER COLUMN So_NRC VARCHAR(64) NULL;
ALTER TABLE dbo.KH_THANHVIEN ALTER COLUMN So_DienThoai VARCHAR(32) NULL;
ALTER TABLE dbo.KH_THANHVIEN ALTER COLUMN Ma_To VARCHAR(32) NULL;
ALTER TABLE dbo.KH_THANHVIEN ALTER COLUMN Ma_Cum VARCHAR(32) NULL;
ALTER TABLE dbo.KH_THANHVIEN ALTER COLUMN Township NVARCHAR(128) NULL;

-- 2. Đồng bộ toàn bộ hồ sơ khách hàng thực tế từ KH_KHANG_HSO sang KH_THANHVIEN
MERGE dbo.KH_THANHVIEN AS target
USING (
    SELECT 
        LTRIM(RTRIM(k.MA_KHANG)) AS Ma_ThanhVien,
        COALESCE(NULLIF(LTRIM(RTRIM(k.TEN_KHANG)), ''), 'BMF Member ' + LTRIM(RTRIM(k.MA_KHANG))) AS Ten_ThanhVien,
        NULLIF(LTRIM(RTRIM(k.DD_GTLQ_SO)), '') AS So_NRC,
        NULLIF(LTRIM(RTRIM(COALESCE(k.SO_DDONG, k.SO_DTHOAI, k.DD_SO_DDONG))), '') AS So_DienThoai,
        kn.MA_NHOM AS Ma_To,
        COALESCE(dn.MA_CUM, 'CTR-YGN-01') AS Ma_Cum,
        COALESCE(k.MA_QUAN, 'Yangon') AS Township,
        1 AS Trang_Thai,
        GETDATE() AS Ngay_GiaNhap
    FROM dbo.KH_KHANG_HSO k
    LEFT JOIN (SELECT MA_KHANG, MIN(MA_NHOM) AS MA_NHOM FROM dbo.KH_KHANG_NHOM GROUP BY MA_KHANG) kn ON k.MA_KHANG = kn.MA_KHANG
    LEFT JOIN dbo.DM_NHOM dn ON kn.MA_NHOM = dn.MA_NHOM
) AS source
ON (target.Ma_ThanhVien = source.Ma_ThanhVien)
WHEN MATCHED THEN
    UPDATE SET
        Ten_ThanhVien = source.Ten_ThanhVien,
        So_NRC = COALESCE(source.So_NRC, target.So_NRC),
        So_DienThoai = COALESCE(source.So_DienThoai, target.So_DienThoai),
        Ma_To = COALESCE(source.Ma_To, target.Ma_To),
        Ma_Cum = COALESCE(source.Ma_Cum, target.Ma_Cum),
        Township = COALESCE(source.Township, target.Township)
WHEN NOT MATCHED THEN
    INSERT (Ma_ThanhVien, Ten_ThanhVien, So_NRC, So_DienThoai, Ma_To, Ma_Cum, Township, Trang_Thai, Ngay_GiaNhap)
    VALUES (source.Ma_ThanhVien, source.Ten_ThanhVien, source.So_NRC, source.So_DienThoai, source.Ma_To, source.Ma_Cum, source.Township, source.Trang_Thai, source.Ngay_GiaNhap);

-- 3. Xóa các tài khoản App User mồ côi không có trong KH_THANHVIEN
DELETE FROM dbo.SYS_APP_USER WHERE Business_Id NOT IN (SELECT Ma_ThanhVien FROM dbo.KH_THANHVIEN);

-- 4. Ràng buộc khóa ngoại an toàn
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SYS_APP_USER_KH_THANHVIEN')
BEGIN
    ALTER TABLE dbo.SYS_APP_USER DROP CONSTRAINT FK_SYS_APP_USER_KH_THANHVIEN;
END

ALTER TABLE dbo.SYS_APP_USER 
ADD CONSTRAINT FK_SYS_APP_USER_KH_THANHVIEN 
FOREIGN KEY (Business_Id) REFERENCES dbo.KH_THANHVIEN(Ma_ThanhVien);

-- 5. Thiết lập dữ liệu mẫu tài khoản đối ứng thật

-- 5.1. Agent Trưởng nhóm đã kích hoạt: 2163896 (KYAW SAN MIN - Trưởng nhóm 000100330401)
-- NRC: 8/PAKHAKA(N)247245 | SĐT: 09970381872 | PIN: 123456
UPDATE dbo.KH_THANHVIEN 
SET Ma_PIN = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
    So_DienThoai = '09970381872',
    So_NRC = '8/PAKHAKA(N)247245'
WHERE Ma_ThanhVien = '2163896';

MERGE dbo.SYS_APP_USER AS target
USING (SELECT 'APP-AGT-2163896' AS User_Id) AS src
ON (target.User_Id = src.User_Id)
WHEN MATCHED THEN
    UPDATE SET
        Business_Id = '2163896',
        Identifier_Key = '2163896',
        Phone_Number = '09970381872',
        Nrc_Number = '8/PAKHAKA(N)247245',
        Full_Name = N'KYAW SAN MIN',
        Pin_Hash = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        Is_Activated = 1,
        Activated_Time = GETDATE(),
        Biometric_Enabled = 1,
        Status = 'ACTIVE',
        Failed_Pin_Attempts = 0
WHEN NOT MATCHED THEN
    INSERT (User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number, Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status, Failed_Pin_Attempts, Created_Time)
    VALUES ('APP-AGT-2163896', 'AGENT', '2163896', '2163896', '09970381872', '8/PAKHAKA(N)247245', N'KYAW SAN MIN', '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', 1, GETDATE(), 1, 'ACTIVE', 0, GETDATE());

-- Tạo thêm tài khoản CUSTOMER cho 2163896 để đăng nhập được cả 2 app
MERGE dbo.SYS_APP_USER AS target
USING (SELECT 'APP-CUST-2163896' AS User_Id) AS src
ON (target.User_Id = src.User_Id)
WHEN MATCHED THEN
    UPDATE SET
        Business_Id = '2163896',
        Identifier_Key = '2163896',
        Phone_Number = '09970381872',
        Nrc_Number = '8/PAKHAKA(N)247245',
        Full_Name = N'KYAW SAN MIN',
        Pin_Hash = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        Is_Activated = 1,
        Activated_Time = GETDATE(),
        Biometric_Enabled = 1,
        Status = 'ACTIVE',
        Failed_Pin_Attempts = 0
WHEN NOT MATCHED THEN
    INSERT (User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number, Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status, Failed_Pin_Attempts, Created_Time)
    VALUES ('APP-CUST-2163896', 'CUSTOMER', '2163896', '2163896', '09970381872', '8/PAKHAKA(N)247245', N'KYAW SAN MIN', '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', 1, GETDATE(), 1, 'ACTIVE', 0, GETDATE());

-- 5.2. Khách hàng đã kích hoạt: 2150001 (AUNG THIHA TUN)
-- NRC: 12/BAHANA(N)097503 | SĐT: 09420076759 | PIN: 123456
UPDATE dbo.KH_THANHVIEN 
SET Ma_PIN = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
    So_DienThoai = '09420076759',
    So_NRC = '12/BAHANA(N)097503'
WHERE Ma_ThanhVien = '2150001';

MERGE dbo.SYS_APP_USER AS target
USING (SELECT 'APP-CUST-2150001' AS User_Id) AS src
ON (target.User_Id = src.User_Id)
WHEN MATCHED THEN
    UPDATE SET
        Business_Id = '2150001',
        Identifier_Key = '2150001',
        Phone_Number = '09420076759',
        Nrc_Number = '12/BAHANA(N)097503',
        Full_Name = N'AUNG THIHA TUN',
        Pin_Hash = '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO',
        Is_Activated = 1,
        Activated_Time = GETDATE(),
        Biometric_Enabled = 1,
        Status = 'ACTIVE',
        Failed_Pin_Attempts = 0
WHEN NOT MATCHED THEN
    INSERT (User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number, Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status, Failed_Pin_Attempts, Created_Time)
    VALUES ('APP-CUST-2150001', 'CUSTOMER', '2150001', '2150001', '09420076759', '12/BAHANA(N)097503', N'AUNG THIHA TUN', '$2a$10$ma75hcydO5zZJEaA8kvzCuKtaDr6RBEFJ3V6B19ONDHerkkwUw/UO', 1, GETDATE(), 1, 'ACTIVE', 0, GETDATE());

-- 5.3. Khách hàng CHƯA kích hoạt: 2150002 (TIN MIN HTUT - Thành viên thường)
-- NRC: 12/PAZATA(N)000534 | SĐT: 09448034049 | Chưa có PIN -> Dùng để test luồng Kích hoạt OTP -> Đặt PIN
UPDATE dbo.KH_THANHVIEN 
SET Ma_PIN = NULL,
    So_DienThoai = '09448034049',
    So_NRC = '12/PAZATA(N)000534'
WHERE Ma_ThanhVien = '2150002';

DELETE FROM dbo.SYS_APP_USER WHERE Business_Id = '2150002';

-- 5.4. Agent Trưởng nhóm CHƯA kích hoạt: 2163980 (KHINE SHWE SIN - Trưởng nhóm 000100230201)
-- NRC: 12/THALANA(N)002347 | SĐT: 09250071850 | Chưa có PIN -> Dùng để test luồng Kích hoạt Agent qua OTP
UPDATE dbo.KH_THANHVIEN 
SET Ma_PIN = NULL,
    So_DienThoai = '09250071850',
    So_NRC = '12/THALANA(N)002347'
WHERE Ma_ThanhVien = '2163980';

DELETE FROM dbo.SYS_APP_USER WHERE Business_Id = '2163980';
