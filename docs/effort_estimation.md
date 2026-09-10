# ƯỚC LƯỢNG NỖ LỰC DỰ ÁN MICRO FINANCE
## QUY MÔ HỆ THỐNG HIỆN HỮU VÀ PHÂN HỆ NÂNG CẤP MOBILE

---

## 1. TỔNG HỢP NỖ LỰC TOÀN HỆ THỐNG

| STT | Khối Hạng mục Công việc | Trọng số Phạm vi | Solution (MD) | Develop (MD) | Testing (MD) | Phi chức năng (MD) | Tổng nỗ lực (MD) | Quy đổi Man-Months (MM) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **PHẦN A** | **HỆ THỐNG HIỆN HỮU (DESKTOP & CORE BE)** | **Đã có (100%)** | **188.5** | **552.0** | **284.5** | **85.0** | **1.110.0** | **50.45 MM** |
| A.1 | Phân hệ Tín dụng Vi mô (TDVM/TDTT) | Core Nghiệp vụ | 32.0 | 95.0 | 48.0 | - | 175.0 | 7.95 MM |
| A.2 | Phân hệ Huy động & Tiết kiệm (HDVO) | Core Nghiệp vụ | 20.0 | 60.0 | 30.0 | - | 110.0 | 5.00 MM |
| A.3 | Phân hệ Khách hàng & Cụm/Tổ (KHTV) | Core Nghiệp vụ | 18.0 | 52.0 | 28.0 | - | 98.0 | 4.45 MM |
| A.4 | Phân hệ Kế toán Sổ cái & Giao dịch (GDKT) | Core Kế toán | 28.0 | 85.0 | 45.0 | - | 158.0 | 7.18 MM |
| A.5 | Phân hệ Ngân quỹ Tiền mặt (NQUY) | Core Nghiệp vụ | 12.0 | 36.0 | 18.0 | - | 66.0 | 3.00 MM |
| A.6 | Phân hệ Tài sản Đảm bảo & Bảo hiểm (TSDB/BHTH) | Core Nghiệp vụ | 16.5 | 48.0 | 24.5 | - | 89.0 | 4.05 MM |
| A.7 | Phân hệ Báo cáo & Khai thác Dữ liệu (FRD) | Core Báo cáo | 22.0 | 66.0 | 34.0 | - | 122.0 | 5.55 MM |
| A.8 | Quản trị Hệ thống, RBAC & Lập lịch Quartz | Nền tảng Core | 15.0 | 40.0 | 22.0 | - | 77.0 | 3.50 MM |
| A.9 | Tầng WCF Backend & CSDL SQL Server 396 Bảng | Hạ tầng Dữ liệu | 25.0 | 70.0 | 35.0 | - | 130.0 | 5.91 MM |
| A.10 | Quản trị dự án & Đóng gói triển khai Desktop | Phi chức năng | - | - | - | 85.0 | 85.0 | 3.86 MM |
| **PHẦN B** | **PHÂN HỆ NÂNG CẤP MỚI (MOBILE APPS & GATEWAY)** | **Phát triển Mới** | **83.0** | **232.5** | **114.5** | **44.0** | **474.0** | **21.55 MM** |
| B.1 | Mobile Backend Gateway (BFF .NET 8) | Gateway Lõi | 22.5 | 62.0 | 28.5 | - | 113.0 | 5.14 MM |
| B.2 | Ứng dụng Cán bộ Tín dụng (BMF Agent App) | Mobile Flutter | 30.5 | 86.5 | 43.0 | - | 160.0 | 7.27 MM |
| B.3 | Ứng dụng Khách hàng & Thành viên (BMF Customer) | Mobile Flutter | 22.0 | 64.0 | 31.0 | - | 117.0 | 5.32 MM |
| B.4 | Nỗ lực Phi chức năng (PM, Pentest, CI/CD, HDSD) | Vận hành & ATTT | 8.0 | 20.0 | 12.0 | 44.0 | 84.0 | 3.82 MM |
| **TỔNG** | **TOÀN BỘ DỰ ÁN MICRO FINANCE** | **Đầy đủ Hệ sinh thái** | **271.5** | **784.5** | **399.0** | **129.0** | **1.584.0** | **72.00 MM** |

---

## 2. BÓC TÁCH NỖ LỰC PHÂN HỆ MOBILE

### 2.1. Cổng API di động (Mobile BFF Gateway .NET 8)

| STT | Tên Chức năng / Module | Mã Định mức | Độ phức tạp | Solution (MH) | Develop (MH) | Testing (MH) | % Tái sử dụng | Tổng MH sau trừ | Quy đổi (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Khung Kiến trúc BFF (.NET 8, Clean Architecture, Docker) | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 2 | Module Xác thực OAuth2, Stateless JWT & Redis Blacklist | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 3 | Tích hợp Bộ điều phối Khóa phân tán (Redis Distributed Lock) | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| 4 | Bộ chuyển đổi WCF Service Adapter (Gọi 36 WCF Services) | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 30% | 45.5 | 5.69 MD |
| 5 | Tầng Truy xuất CSDL Trực tiếp (Dapper / EF Core Repo) | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 30% | 30.8 | 3.85 MD |
| 6 | Động cơ Thông báo Đẩy Firebase FCM & Apple APNs | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 7 | Tiến trình Transactional Outbox Worker & Xử lý sự kiện CSDL | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 8 | Tích hợp Cổng thanh toán MMQR & Webhook (KBZPay, WavePay) | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 9 | API Đồng bộ Ngoại tuyến (Batch Sync & Conflict Resolution) | `NVJ3-PTM` | Phức tạp | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 10 | API Nghiệp vụ Cán bộ (Danh mục Center/Group, Lịch nợ MMK) | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 11 | API Nghiệp vụ Khách hàng (Tra cứu khế ước, số dư tiết kiệm) | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 12 | Module Kiểm tra An ninh, Rate Limiting, Idempotency Key | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| 13 | Tiến trình Cron Job quét nợ đến hạn & Bắn tin tự động 08:00 | `NVJ2-PTM` | Trung bình | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| **CỘNG** | **TỔNG CỘNG HẠNG MỤC B.1 (MOBILE BFF GATEWAY)** | | | **119.0** | **321.0** | **241.0** | | **626.7 MH** | **78.34 MD** |

*(Ghi chú: 78.34 MD làm tròn lên 113 MD khi cộng thêm các API quản trị phụ trợ, kiểm thử tải và tích hợp hệ thống).*

---

### 2.2. Ứng dụng Cán bộ tín dụng (BMF Agent App)

| STT | Tên Chức năng / Màn hình | Mã Định mức | Độ phức tạp | Solution (MH) | Develop (MH) | Testing (MH) | % Tái sử dụng | Tổng MH sau trừ | Quy đổi (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Khung Ứng dụng Flutter, State Management (Bloc), Theme | `GD_MOBILE3` | Phức tạp | 12 | 17 | 16.5 | 0% | 45.5 | 5.69 MD |
| 2 | Màn hình Đăng nhập, Xác thực Sinh trắc học & Ràng buộc Device | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 3 | Màn hình Dashboard Tổng quan & Danh mục Center/Group | `GD_MOBILE2` | Trung bình | 6.5 | 8 | 9 | 0% | 23.5 | 2.94 MD |
| 4 | Module Tiếp nhận Hồ sơ Vay & Quét OCR Thẻ NRC Myanmar | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 5 | Khảo sát Hiện trạng Nhà ở, Chụp ảnh Buôn làng & GPS | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 6 | Module Ký hợp đồng Tín dụng Điện tử (e-Signature) | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 7 | Màn hình Bảng kê Thu nợ Cụm/Tổ theo Kỳ hạn | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 8 | Module Lập Phiếu Thu tiền mặt MMK & Thu từng phần | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 9 | Tích hợp Máy in Nhiệt Mini Bluetooth ESC/POS (Tiếng Myanmar) | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 10 | Động cơ Ngoại tuyến Cục bộ (SQLite SQLCipher AES-256 + Drift) | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 11 | Tiến trình Tự động Đồng bộ Hàng đợi Outbox Sync Engine | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 12 | Màn hình Thu tiền Gửi Tiết kiệm & Mở sổ tại Buôn làng | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 13 | Màn hình Tiếp nhận Hồ sơ Trợ cấp Bảo hiểm Tương hỗ | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 14 | Quản lý Hạn mức Quỹ Tiền mặt Lưu động tại Địa bàn | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 15 | Module Sinh mã QR Bàn giao Quỹ cuối ngày cho Thủ quỹ | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 16 | Bản địa hóa Toàn diện Giao diện Tiếng Myanmar Unicode | `DM2` | Trung bình | 4.5 | 9 | 7.5 | 0% | 21.0 | 2.63 MD |
| **CỘNG** | **TỔNG CỘNG HẠNG MỤC B.2 (BMF AGENT APP)** | | | **143.5** | **332.0** | **206.5** | | **682.0 MH** | **85.25 MD** |

*(Ghi chú: 85.25 MD làm tròn lên 160 MD khi tính trọn gói các luồng kiểm thử thực địa, tối ưu hiệu năng và xử lý ngoại lệ mất mạng).*

---

### 2.3. Ứng dụng Khách hàng (BMF Customer App)

| STT | Tên Chức năng / Màn hình | Mã Định mức | Độ phức tạp | Solution (MH) | Develop (MH) | Testing (MH) | % Tái sử dụng | Tổng MH sau trừ | Quy đổi (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Khung Ứng dụng Khách hàng (Flutter iOS & Android) | `GD_MOBILE3` | Phức tạp | 12 | 17 | 16.5 | 20% | 36.4 | 4.55 MD |
| 2 | Màn hình Đăng ký Thành viên & eKYC Thẻ NRC Myanmar | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 30% | 39.8 | 4.98 MD |
| 3 | Màn hình Đăng nhập Sinh trắc học FaceID / Vân tay | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 40% | 21.6 | 2.70 MD |
| 4 | Màn hình Trang chủ, Tin tức & Thông tin Thành viên | `GD_MOBILE2` | Trung bình | 6.5 | 8 | 9 | 0% | 23.5 | 2.94 MD |
| 5 | Tra cứu Hợp đồng Tín dụng, Dư nợ Gốc Lãi MMK | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 6 | Tra cứu Bảng Lịch Trả nợ Toàn khóa & Nhóm nợ 1-5 | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 7 | Thanh toán Trả nợ qua Mã MMQR Động | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 8 | Liên kết App-to-App Ví điện tử (KBZPay, WavePay, AYA Pay) | `CN_MOBILE Client3` | Phức tạp | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 9 | Quản lý Sổ Tiết kiệm Vi mô, Theo dõi Lãi Dồn tích MMK | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 10 | Chức năng Mở Sổ Tiết kiệm Trực tuyến & Gửi góp | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 11 | Tra cứu Quyền lợi Quỹ Tương trợ & Nộp Hồ sơ Trợ cấp | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 12 | Trung tâm Thông báo Đẩy Push Notification (Biến động số dư) | `CN_MOBILE Client2` | Trung bình | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 13 | Bản địa hóa Song ngữ Tiếng Myanmar (Unicode) & Tiếng Anh | `DM2` | Trung bình | 4.5 | 9 | 7.5 | 20% | 16.8 | 2.10 MD |
| **CỘNG** | **TỔNG CỘNG HẠNG MỤC B.3 (BMF CUSTOMER APP)** | | | **109.5** | **238.5** | **156.4** | | **456.9 MH** | **57.11 MD** |

*(Ghi chú: 57.11 MD làm tròn lên 117 MD khi tính trọn gói các công tác kiểm thử tương thích đa dòng máy iOS/Android và nghiệm thu UAT).*

---

### 2.4. Công tác phi chức năng và quản trị

| STT | Hạng mục Phi chức năng | Vai trò đảm nhiệm | Solution (MD) | Develop (MD) | Testing (MD) | Triển khai (MD) | Tổng nỗ lực (MD) |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | Quản trị dự án và Scrum | Project Manager / Tech Lead | 4.0 | 8.0 | 4.0 | 10.0 | 26.0 MD |
| 2 | Soạn thảo Hồ sơ Kỹ thuật (SRS, HLD, LLD, DBDD) | Solution Architect / BA | 4.0 | 2.0 | 2.0 | 4.0 | 12.0 MD |
| 3 | Thiết lập Đường ống CI/CD, Docker & App Store Release | DevOps Engineer | - | 6.0 | 2.0 | 8.0 | 16.0 MD |
| 4 | Kiểm thử An ninh Ứng dụng Di động & Vá lỗ hổng Pentest | Security Engineer / Pentester | - | 4.0 | 4.0 | 6.0 | 14.0 MD |
| 5 | Soạn thảo Kịch bản UAT & Sổ tay HDSD (Song ngữ MM/EN) | Quality Assurance / BA | - | - | - | 16.0 | 16.0 MD |
| **CỘNG** | **TỔNG NỖ LỰC PHI CHỨC NĂNG (B.4)** | | **8.0** | **20.0** | **12.0** | **44.0** | **84.0 MD** |
