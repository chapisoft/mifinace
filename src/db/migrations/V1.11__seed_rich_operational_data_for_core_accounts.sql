-- ====================================================================================
-- MIGRATION: V1.11__seed_rich_operational_data_for_core_accounts.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MỤC TIÊU:
-- 1. Nạp dữ liệu nghiệp vụ thực tế hoàn chỉnh cho Tài khoản Khách hàng chuẩn 2150001 (AUNG THIHA TUN).
-- 2. Nạp dữ liệu nghiệp vụ tổ vay vốn thực địa cho Agent Trưởng nhóm 2163896 (KYAW SAN MIN - Nhóm 000100330401).
-- 3. Cung cấp đầy đủ Hợp đồng tín dụng (TD_HOPDONG), Lịch thu nợ 12 kỳ (TD_LICH_THUNO),
--    Giao dịch thanh toán (SYS_REPAYMENT_TRANSACTION), Sổ tiết kiệm (SYS_SAVING_ACCOUNT) và Lịch sử gửi tiền (SYS_SAVING_TRANSACTION).
-- ====================================================================================

-- 1. ĐỒNG BỘ ĐỊNH DANH THÀNH VIÊN VÀ NHÓM VAY VỐN
UPDATE dbo.KH_THANHVIEN
SET Ma_To = '000100330401',
    Ma_Cum = 'CTR-YGN-01',
    Township = N'Dagon Township'
WHERE Ma_ThanhVien IN ('2150001', '2163896', '2150002');

-- 2. DỮ LIỆU TÍN DỤNG CHO KHÁCH HÀNG 2150001 (AUNG THIHA TUN)
-- Hợp đồng vay vốn vi mô: HD-2026-2150001 (Gói MICRO_BIZ_01, 1,500,000 MMK, 28%/năm, 12 kỳ)
MERGE dbo.TD_HOPDONG AS target
USING (VALUES
    ('HD-2026-2150001', '2150001', '000100330401', 'MICRO_BIZ_01', 1500000.00, 28.00, DATEADD(MONTH, -5, GETDATE()), DATEADD(MONTH, 7, GETDATE()), 12, 'ACTIVE')
) AS source (Ma_HopDong, Ma_ThanhVien, Ma_To, Goi_Vay, So_Tien_Vay, Lai_Suat_Nam, Ngay_GiaiNgan, Ngay_DaoHan, So_Ky_Vay, Trang_Thai)
ON (target.Ma_HopDong = source.Ma_HopDong)
WHEN MATCHED THEN
    UPDATE SET
        Ma_ThanhVien = source.Ma_ThanhVien,
        Ma_To = source.Ma_To,
        So_Tien_Vay = source.So_Tien_Vay,
        Trang_Thai = source.Trang_Thai
WHEN NOT MATCHED THEN
    INSERT (Ma_HopDong, Ma_ThanhVien, Ma_To, Goi_Vay, So_Tien_Vay, Lai_Suat_Nam, Ngay_GiaiNgan, Ngay_DaoHan, So_Ky_Vay, Trang_Thai)
    VALUES (source.Ma_HopDong, source.Ma_ThanhVien, source.Ma_To, source.Goi_Vay, source.So_Tien_Vay, source.Lai_Suat_Nam, source.Ngay_GiaiNgan, source.Ngay_DaoHan, source.So_Ky_Vay, source.Trang_Thai);

-- Lịch trả nợ 12 kỳ của HD-2026-2150001:
-- Kỳ 1..5: Đã thanh toán (SETTLED)
-- Kỳ 6: Đến hạn hôm nay (DUE_TODAY, gốc 50,000, lãi 6,250, BH 1,000, TK 2,000 => Tổng 59,250 MMK)
-- Kỳ 7..12: Sắp tới (PENDING)
DELETE FROM dbo.TD_LICH_THUNO WHERE Ma_HopDong = 'HD-2026-2150001';

DECLARE @Per INT = 1;
WHILE @Per <= 12
BEGIN
    DECLARE @DueDt DATE = CAST(DATEADD(MONTH, @Per - 6, GETDATE()) AS DATE);
    DECLARE @St VARCHAR(16) = CASE 
        WHEN @Per < 6 THEN 'SETTLED'
        WHEN @Per = 6 THEN 'DUE_TODAY'
        ELSE 'PENDING'
    END;

    INSERT INTO dbo.TD_LICH_THUNO (Ma_HopDong, Ky_Thu, Tien_Goc, Tien_Lai, Phi_BaoHiem, TietKiem_BatBuoc, Tong_Tien, Ngay_DenHan, Trang_Thai)
    VALUES ('HD-2026-2150001', @Per, 50000.00, 6250.00, 1000.00, 2000.00, 59250.00, @DueDt, @St);

    SET @Per = @Per + 1;
END;

-- 3. GIAO DỊCH LỊCH SỬ CHO KHÁCH HÀNG 2150001 (SYS_REPAYMENT_TRANSACTION)
MERGE dbo.SYS_REPAYMENT_TRANSACTION AS target
USING (VALUES
    ('TX-2150001-01', 'HD-2026-2150001', '2150001', N'AUNG THIHA TUN', '000100330401', 1, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-2150001-01', '2163896', DATEADD(MONTH, -5, GETDATE()), 'SETTLED', N'Field collection period 1 at village center'),
    ('TX-2150001-02', 'HD-2026-2150001', '2150001', N'AUNG THIHA TUN', '000100330401', 2, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'KBZ_PAY', 'IDEM-2150001-02', '2163896', DATEADD(MONTH, -4, GETDATE()), 'SETTLED', N'Installment period 2 settled via KBZPay'),
    ('TX-2150001-03', 'HD-2026-2150001', '2150001', N'AUNG THIHA TUN', '000100330401', 3, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'WAVE_PAY', 'IDEM-2150001-03', '2163896', DATEADD(MONTH, -3, GETDATE()), 'SETTLED', N'Installment period 3 settled via WavePay'),
    ('TX-2150001-04', 'HD-2026-2150001', '2150001', N'AUNG THIHA TUN', '000100330401', 4, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'CASH', 'IDEM-2150001-04', '2163896', DATEADD(MONTH, -2, GETDATE()), 'SETTLED', N'Over-the-counter collection period 4 at center'),
    ('TX-2150001-05', 'HD-2026-2150001', '2150001', N'AUNG THIHA TUN', '000100330401', 5, 50000.00, 6250.00, 1000.00, 2000.00, 0.00, 59250.00, 'MMQR', 'IDEM-2150001-05', '2163896', DATEADD(MONTH, -1, GETDATE()), 'SETTLED', N'Digital repayment period 5 via MMQR scan')
) AS source (
    Transaction_ID, Contract_Code, Customer_Code, Customer_Name, Group_Code,
    Period_Number, Principal_Amount, Interest_Amount, Insurance_Fee, Compulsory_Saving,
    Penalty_Amount, Total_Amount, Payment_Method, Idempotency_Key, Collected_By,
    Collected_Time, Status, Notes
)
ON (target.Transaction_ID = source.Transaction_ID)
WHEN MATCHED THEN
    UPDATE SET
        Customer_Code = source.Customer_Code,
        Customer_Name = source.Customer_Name,
        Contract_Code = source.Contract_Code,
        Total_Amount = source.Total_Amount,
        Status = source.Status
WHEN NOT MATCHED THEN
    INSERT (Transaction_ID, Contract_Code, Customer_Code, Customer_Name, Group_Code,
            Period_Number, Principal_Amount, Interest_Amount, Insurance_Fee, Compulsory_Saving,
            Penalty_Amount, Total_Amount, Payment_Method, Idempotency_Key, Collected_By,
            Collected_Time, Status, Notes)
    VALUES (source.Transaction_ID, source.Contract_Code, source.Customer_Code, source.Customer_Name, source.Group_Code,
            source.Period_Number, source.Principal_Amount, source.Interest_Amount, source.Insurance_Fee, source.Compulsory_Saving,
            source.Penalty_Amount, source.Total_Amount, source.Payment_Method, source.Idempotency_Key, source.Collected_By,
            source.Collected_Time, source.Status, source.Notes);

-- 4. SỔ TIẾT KIỆM CHO KHÁCH HÀNG 2150001
MERGE dbo.SYS_SAVING_ACCOUNT AS target
USING (VALUES
    ('SAV-2150001-01', '2150001', N'AUNG THIHA TUN', 'COMPULSORY', 120000.00, 10.00, 12, N'Daw Mya Mya', '12/BAHANA(N)097504', 'ACTIVE', 'SYSTEM', DATEADD(MONTH, -5, GETDATE())),
    ('SAV-2150001-02', '2150001', N'AUNG THIHA TUN', 'VOLUNTARY', 350000.00, 14.00, 12, N'Daw Mya Mya', '12/BAHANA(N)097504', 'ACTIVE', '2163896', DATEADD(MONTH, -3, GETDATE()))
) AS source (
    Account_Number, Customer_Code, Customer_Name, Product_Type,
    Balance, Interest_Rate, Term_Months, Beneficiary_Name, Beneficiary_NRC,
    Status, Created_By, Created_Time
)
ON (target.Account_Number = source.Account_Number)
WHEN MATCHED THEN
    UPDATE SET
        Customer_Code = source.Customer_Code,
        Customer_Name = source.Customer_Name,
        Balance = source.Balance,
        Status = source.Status
WHEN NOT MATCHED THEN
    INSERT (Account_Number, Customer_Code, Customer_Name, Product_Type,
            Balance, Interest_Rate, Term_Months, Beneficiary_Name, Beneficiary_NRC,
            Status, Created_By, Created_Time)
    VALUES (source.Account_Number, source.Customer_Code, source.Customer_Name, source.Product_Type,
            source.Balance, source.Interest_Rate, source.Term_Months, source.Beneficiary_Name, source.Beneficiary_NRC,
            source.Status, source.Created_By, source.Created_Time);

-- 5. THÊM CÁC HỢP ĐỒNG CHO CÁC THÀNH VIÊN KHÁC TRONG NHÓM 000100330401 ĐỂ AGENT 2163896 THU TIỀN VÀ TEST ĐỒNG BỘ
MERGE dbo.TD_HOPDONG AS target
USING (VALUES
    ('HD-2026-2163896', '2163896', '000100330401', 'MICRO_BIZ_01', 2000000.00, 28.00, DATEADD(MONTH, -4, GETDATE()), DATEADD(MONTH, 8, GETDATE()), 12, 'ACTIVE')
) AS source (Ma_HopDong, Ma_ThanhVien, Ma_To, Goi_Vay, So_Tien_Vay, Lai_Suat_Nam, Ngay_GiaiNgan, Ngay_DaoHan, So_Ky_Vay, Trang_Thai)
ON (target.Ma_HopDong = source.Ma_HopDong)
WHEN MATCHED THEN
    UPDATE SET
        Ma_ThanhVien = source.Ma_ThanhVien,
        Ma_To = source.Ma_To,
        So_Tien_Vay = source.So_Tien_Vay,
        Trang_Thai = source.Trang_Thai
WHEN NOT MATCHED THEN
    INSERT (Ma_HopDong, Ma_ThanhVien, Ma_To, Goi_Vay, So_Tien_Vay, Lai_Suat_Nam, Ngay_GiaiNgan, Ngay_DaoHan, So_Ky_Vay, Trang_Thai)
    VALUES (source.Ma_HopDong, source.Ma_ThanhVien, source.Ma_To, source.Goi_Vay, source.So_Tien_Vay, source.Lai_Suat_Nam, source.Ngay_GiaiNgan, source.Ngay_DaoHan, source.So_Ky_Vay, source.Trang_Thai);

DELETE FROM dbo.TD_LICH_THUNO WHERE Ma_HopDong = 'HD-2026-2163896';

DECLARE @Per2 INT = 1;
WHILE @Per2 <= 12
BEGIN
    DECLARE @DueDt2 DATE = CAST(DATEADD(MONTH, @Per2 - 5, GETDATE()) AS DATE);
    DECLARE @St2 VARCHAR(16) = CASE 
        WHEN @Per2 < 5 THEN 'SETTLED'
        WHEN @Per2 = 5 THEN 'DUE_TODAY'
        ELSE 'PENDING'
    END;

    INSERT INTO dbo.TD_LICH_THUNO (Ma_HopDong, Ky_Thu, Tien_Goc, Tien_Lai, Phi_BaoHiem, TietKiem_BatBuoc, Tong_Tien, Ngay_DenHan, Trang_Thai)
    VALUES ('HD-2026-2163896', @Per2, 70000.00, 8500.00, 1000.00, 2000.00, 81500.00, @DueDt2, @St2);

    SET @Per2 = @Per2 + 1;
END;
