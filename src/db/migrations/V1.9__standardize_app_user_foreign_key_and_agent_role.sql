-- ====================================================================================
-- MIGRATION: V1.9__standardize_app_user_foreign_key_and_agent_role.sql
-- MỤC TIÊU: Chuẩn hóa bảng SYS_APP_USER liên kết khóa ngoại với KH_THANHVIEN(Ma_ThanhVien),
--          dùng Ma_ThanhVien làm Identifier_Key/Username và định hình đúng Role AGENT
--          (Agent là Khách hàng trưởng nhóm/cụm trong KH_THANHVIEN).
-- ====================================================================================

-- 1. Xóa các dữ liệu cũ không khớp khóa ngoại
DELETE FROM dbo.SYS_APP_USER WHERE Business_Id NOT IN (SELECT Ma_ThanhVien FROM dbo.KH_THANHVIEN);

-- 2. Cập nhật nhóm và trưởng nhóm mẫu
IF NOT EXISTS (SELECT 1 FROM dbo.DM_TO WHERE Ma_To = 'GRP-YGN-01')
BEGIN
    INSERT INTO dbo.DM_TO (Ma_To, Ten_To, Ma_Cum, Nhom_Truong, Trang_Thai)
    VALUES ('GRP-YGN-01', N'Solidarity Group 01', 'CTR-YGN-01', 'CUST-001', 1);
END
ELSE
BEGIN
    UPDATE dbo.DM_TO SET Nhom_Truong = 'CUST-001' WHERE Ma_To = 'GRP-YGN-01';
END

IF NOT EXISTS (SELECT 1 FROM dbo.DM_NHOM WHERE MA_NHOM = 'GRP-YGN-01')
BEGIN
    INSERT INTO dbo.DM_NHOM (MA_NHOM, TEN_NHOM, MA_CUM, MA_NHOM_TRUONG, TTHAI_BGHI, TTHAI_NVU)
    VALUES ('GRP-YGN-01', N'Solidarity Group 01', 'CTR-YGN-01', 'CUST-001', 'A', 'A');
END
ELSE
BEGIN
    UPDATE dbo.DM_NHOM SET MA_NHOM_TRUONG = 'CUST-001' WHERE MA_NHOM = 'GRP-YGN-01';
END

-- 3. Tạo ràng buộc khóa ngoại từ SYS_APP_USER(Business_Id) sang KH_THANHVIEN(Ma_ThanhVien)
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SYS_APP_USER_KH_THANHVIEN')
BEGIN
    ALTER TABLE dbo.SYS_APP_USER DROP CONSTRAINT FK_SYS_APP_USER_KH_THANHVIEN;
END

ALTER TABLE dbo.SYS_APP_USER 
ADD CONSTRAINT FK_SYS_APP_USER_KH_THANHVIEN 
FOREIGN KEY (Business_Id) REFERENCES dbo.KH_THANHVIEN(Ma_ThanhVien);

-- 4. Seed dữ liệu mẫu chuẩn hóa với Ma_ThanhVien làm Username/Identifier_Key
-- CUST-001 (Daw Khin Myint - Vừa là Khách hàng vừa là Agent Trưởng nhóm)
IF NOT EXISTS (SELECT 1 FROM dbo.SYS_APP_USER WHERE User_Id = 'APP-CUST-001')
BEGIN
    INSERT INTO dbo.SYS_APP_USER (
        User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
        Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status,
        Failed_Pin_Attempts, Created_Time
    ) VALUES (
        'APP-CUST-001', 'CUSTOMER', 'CUST-001', 'CUST-001', '09123456789', '12/DAGAMA(N)045612',
        N'Daw Khin Myint', '$2a$10$wO3Y153fKz0oD0X0wF6gmeB7KzKzKzKzKzKzKzKzKzKzKzKzKzKzK', 1, GETDATE(), 1, 'ACTIVE',
        0, GETDATE()
    );
END
ELSE
BEGIN
    UPDATE dbo.SYS_APP_USER 
    SET Identifier_Key = 'CUST-001', Business_Id = 'CUST-001', Phone_Number = '09123456789'
    WHERE User_Id = 'APP-CUST-001';
END

-- Seed tài khoản AGENT cho CUST-001 (Trưởng nhóm)
IF NOT EXISTS (SELECT 1 FROM dbo.SYS_APP_USER WHERE User_Id = 'APP-AGT-CUST-001')
BEGIN
    INSERT INTO dbo.SYS_APP_USER (
        User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
        Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status,
        Failed_Pin_Attempts, Created_Time
    ) VALUES (
        'APP-AGT-CUST-001', 'AGENT', 'CUST-001', 'CUST-001', '09123456789', '12/DAGAMA(N)045612',
        N'Daw Khin Myint', '$2a$10$wO3Y153fKz0oD0X0wF6gmeB7KzKzKzKzKzKzKzKzKzKzKzKzKzKzK', 1, GETDATE(), 1, 'ACTIVE',
        0, GETDATE()
    );
END
ELSE
BEGIN
    UPDATE dbo.SYS_APP_USER 
    SET Identifier_Key = 'CUST-001', Business_Id = 'CUST-001', Phone_Number = '09123456789'
    WHERE User_Id = 'APP-AGT-CUST-001';
END

-- CUST-002 (U Thant Zin - Thành viên vay vốn)
IF NOT EXISTS (SELECT 1 FROM dbo.SYS_APP_USER WHERE User_Id = 'APP-CUST-002')
BEGIN
    INSERT INTO dbo.SYS_APP_USER (
        User_Id, User_Type, Business_Id, Identifier_Key, Phone_Number, Nrc_Number,
        Full_Name, Pin_Hash, Is_Activated, Activated_Time, Biometric_Enabled, Status,
        Failed_Pin_Attempts, Created_Time
    ) VALUES (
        'APP-CUST-002', 'CUSTOMER', 'CUST-002', 'CUST-002', '09450098765', '12/DAGAMA(N)078901',
        N'U Thant Zin', '$2a$10$wO3Y153fKz0oD0X0wF6gmeB7KzKzKzKzKzKzKzKzKzKzKzKzKzKzK', 1, GETDATE(), 1, 'ACTIVE',
        0, GETDATE()
    );
END
ELSE
BEGIN
    UPDATE dbo.SYS_APP_USER 
    SET Identifier_Key = 'CUST-002', Business_Id = 'CUST-002', Phone_Number = '09450098765'
    WHERE User_Id = 'APP-CUST-002';
END
