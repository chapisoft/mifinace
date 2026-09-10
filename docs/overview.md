# PHÂN TÍCH KIẾN TRÚC VÀ MÃ NGUỒN NG.mFinance

---

## 1. TỔNG QUAN HỆ THỐNG VÀ CÔNG NGHỆ

### 1.1. Bối cảnh dự án BMF Myanmar
Hệ thống NG.mFinance (Micro Finance Platform) là giải pháp phần mềm quản trị nghiệp vụ Tài chính Vi mô và Core Banking chuyên sâu, được đóng gói và triển khai thực tế cho tổ chức tài chính vi mô **BMF (Bago Microfinance)** tại thị trường Myanmar trên cơ sở dữ liệu `NG-mFINA-BMF_20180402`.

Hệ thống quản lý toàn diện vòng đời tín dụng vi mô, huy động vốn tiết kiệm, kế toán hạch toán kép, quản lý ngân quỹ tiền mặt, bảo hiểm tương hỗ, phân loại nợ tự động theo quy định của **Cục Quản lý Tài chính Vi mô Myanmar (FRD)**, hỗ trợ đơn vị tiền tệ **MMK (Myanmar Kyat)**, quản lý định danh công dân qua **Thẻ căn cước công dân Myanmar (NRC)** và xuất bản hệ thống báo cáo tài chính, quản trị đa chiều.

### 1.2. Phân vùng an ninh hệ thống

```mermaid
%%{init: {'flowchart': {'nodeSpacing': 14, 'rankSpacing': 24, 'padding': 8}, 'themeVariables': {'fontSize': '13px', 'fontFamily': 'Inter, Arial, sans-serif'}}}%%
flowchart TD
    %% 1. VÙNG TRUY CẬP KHÁCH HÀNG & MẠNG NGOÀI
    subgraph ZONE_ACCESS ["1. KÊNH TRUY CẬP NGƯỜI DÙNG & MẠNG NGOÀI"]
        direction LR
        C_WPF["Desktop Client WPF Ribbon<br/>• Quản trị & Nghiệp vụ tại Quầy<br/>• Telerik UI & WPFToolkit Controls"]:::cClient ~~~ C_WEB["Web Portal Dịch vụ<br/>• Tra cứu & Báo cáo trực tuyến<br/>• Dịch vụ AutoUpdate Client WCF"]:::cClient ~~~ C_MOB["Kênh Thu nợ Lưu động<br/>• Cán bộ tín dụng tại Cụm/Tổ<br/>• Máy in nhiệt hóa đơn Bluetooth"]:::cClient ~~~ C_EXT["Kênh Đối tác & Viễn thông<br/>• Cổng SMS Gateway / GSM Modem<br/>• Kênh Sao kê Ngân hàng Thương mại"]:::cExt
    end

    %% 2. VÙNG DMZ DẢI NGOÀI
    subgraph ZONE_DMZ ["2. VÙNG DMZ / BIÊN AN NINH DẢI NGOÀI"]
        direction LR
        DMZ_LB["Cân bằng tải & Tường lửa WAF<br/>• Cụm NGINX Reverse Proxy<br/>• Chống tấn công L4/L7 & SSL TLS"]:::cDmz ~~~ DMZ_GW["Cổng Web Portal & Cổng API<br/>• PresentationAspNet.MVC (Port 80)<br/>• Cổng tiếp nhận AutoUpdate Service"]:::cDmz ~~~ DMZ_VSA["Kiểm soát Xác thực Biên<br/>• Quản lý phiên truy cập tập trung<br/>• Mã hóa cấu hình giải thuật DES"]:::cDmz
    end

    %% 3. VÙNG DẢI TRONG ỨNG DỤNG NGHIỆP VỤ LÕI
    subgraph ZONE_INT ["3. VÙNG DẢI TRONG / ỨNG DỤNG NGHIỆP VỤ LÕI"]
        direction TB
        subgraph SRV_HOST ["Cụm Máy chủ Host Dịch vụ WCF (Hosts.WebHost IIS / Hosts.WinHost Service)"]
            direction LR
            S_COMM["Tầng Giao tiếp Dịch vụ<br/>• 36 CommunicationServices WCF<br/>• BasicHttpBinding & NetTcpBinding<br/>• Buffer 2GB & DataContract Serialization"]:::cCore ~~~ S_PROC["Tầng Điều phối Nghiệp vụ Lõi<br/>• 39 BusinessServices Modules<br/>• Tính lãi Niên kim & Dư nợ giảm dần<br/>• Phân loại nợ 5 nhóm & DPRR tự động"]:::cCore
        end

        subgraph SRV_JOB ["Cụm Tác vụ Ngầm & Thông tin Liên lạc"]
            direction LR
            S_SCHED["Tiến trình Lập lịch Quartz.NET<br/>• Đóng sổ cuối ngày COB tự động<br/>• Trích lãi dồn tích & Bút toán định kỳ"]:::cKafka ~~~ S_SMS["Cổng Xử lý Tin nhắn SMS<br/>• BusinessServices.SMSGSMCom<br/>• Giao tiếp Modem GSM AT Commands"]:::cKafka
        end

        SRV_HOST ~~~ SRV_JOB
    end

    %% 4. VÙNG QUẢN TRỊ & VẬN HÀNH PRIVATE OAM
    subgraph ZONE_OAM ["4. VÙNG QUẢN TRỊ & VẬN HÀNH PRIVATE OAM"]
        direction LR
        OAM_MIG["Công cụ Chuyển đổi Dữ liệu<br/>• PresentationWPF.DataMigration<br/>• Import dữ liệu lịch sử hệ thống cũ"]:::cOam ~~~ OAM_MON["Giám sát Máy chủ Monitor<br/>• PresentationWPF.Monitor App<br/>• Giám sát phiên & Kết nối WCF"]:::cOam ~~~ OAM_LOG["Quản lý Nhật ký Kiểm toán<br/>• Tích hợp log4net Logging<br/>• Audit Log giao dịch tài chính 24/7"]:::cOam
    end

    %% 5. VÙNG CƠ SỞ DỮ LIỆU & LƯU TRỮ
    subgraph ZONE_DB ["5. VÙNG CƠ SỞ DỮ LIỆU & LƯU TRỮ BỀN VỮNG"]
        direction LR
        DB_SQL["Cơ sở Dữ liệu SQL Server Cluster<br/>• Stored Procedures & DataModel.ADO<br/>• Ánh xạ ORM DataModel.EntityFramework<br/>• Quản lý giao dịch nguyên tử txScope"]:::cDb ~~~ DB_BAK["Hạ tầng Sao lưu Định kỳ<br/>• Backup tự động hàng ngày<br/>• Lưu trữ tệp tin nén qua SharpZipLib"]:::cDb
    end

    %% LUỒNG TRUYỀN THÔNG LIÊN PHÂN VÙNG
    ZONE_ACCESS -->|"1. HTTPS / WCF TCP Port 8000 / 8080"| ZONE_DMZ
    ZONE_DMZ ==>|"2. Tường lửa Dải Trong & Định tuyến WCF Service"| ZONE_INT
    ZONE_INT -->|"3. Giao thức TDS SQL Server Port 1433"| ZONE_DB
    ZONE_OAM -.->|"4. Quản trị & Đối soát Nghiệp vụ (VPN LAN)"| ZONE_INT
    ZONE_OAM -.->|"5. Truy vấn Báo cáo & QL Dữ liệu (Port 1433)"| ZONE_DB

    %% KHAI BÁO CLASS STYLES
    classDef cClient fill:#e8f4fd,stroke:#2b6cb0,stroke-width:1.5px,color:#1a365d;
    classDef cExt fill:#f1f5f9,stroke:#475569,stroke-width:1.5px,color:#0f172a;
    classDef cDmz fill:#fef3c7,stroke:#d97706,stroke-width:1.5px,color:#78350f;
    classDef cCore fill:#ecfdf5,stroke:#059669,stroke-width:1.5px,color:#064e3b;
    classDef cKafka fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px,color:#881337;
    classDef cOam fill:#eff6ff,stroke:#3b82f6,stroke-width:1.5px,color:#1e3a8a;
    classDef cDb fill:#f5f3ff,stroke:#7c3aed,stroke-width:1.5px,color:#4c1d95;
```

### 1.3. Đặc tả phân vùng an ninh 5 lớp

| Phân vùng an ninh | Tên máy chủ / Container | Cụm dịch vụ / Phân hệ cài đặt | Cổng dịch vụ & Giao thức | Chức năng cốt lõi & Cơ chế an ninh |
| :--- | :--- | :--- | :--- | :--- |
| **1. Kênh Truy cập Người dùng** | Client Workstation / Mobile | Giao diện Desktop WPF Ribbon, Cổng Web Portal, Kênh thu nợ lưu động | HTTPS (443), WCF TCP (8000), Bluetooth | Cung cấp giao diện làm việc cho cán bộ tín dụng và giao dịch viên; đóng gói proxy trung gian Presentation.Process tối ưu hóa tuần tự hóa dữ liệu. |
| **2. Vùng DMZ Biên An ninh** | `micro-server` (Nginx Master) | Cụm NGINX Reverse Proxy, PresentationAspNet.MVC, FRP Client Service | TCP 80, 443 (Trỏ qua `https://mfina.microtec.vn/`) | Tiếp nhận kết nối mạng ngoài từ VPS FRP Gateway (35.247.156.176), phân tải yêu cầu và chuyển tiếp an toàn vào container nghiệp vụ. |
| **3. Vùng Nghiệp vụ Lõi (Dải Trong)** | `micro-finance-app` (Docker) | WCF SOAP Services (.NET 4.0 / Mono XSP4), 36 CommunicationServices, 39 BusinessServices | TCP 1011 (Nội bộ), COM/Serial Port (GSM SMS) | Thực thi toàn bộ quy tắc nghiệp vụ tài chính vi mô, tính toán lịch thu nợ, hạch toán kép, phân loại nợ 5 nhóm, trích lập dự phòng và đóng sổ cuối ngày. Đường dẫn: `/data/uc1-software/apps/micro-finance/`. |
| **4. Vùng Quản trị Private OAM** | `micro-server` (LAN / SSH) | PresentationWPF.DataMigration, PresentationWPF.Monitor, Cụm ELK & Prometheus/Grafana | TCP 65000 (SSH), TCP 5601 (Kibana), TCP 3003 (Grafana) | Chuyển đổi dữ liệu hệ thống cũ, giám sát trạng thái máy chủ, quản lý phiên làm việc và theo dõi nhật ký kiểm toán hệ thống qua `https://monitor.microtec.vn/` & `https://kibana.microtec.vn/`. |
| **5. Vùng Cơ sở Dữ liệu** | `mssql-db` (Docker SQL Server 2017) | Microsoft SQL Server 2017 (`NG-mFINA-BMF_20180402` - 396 bảng), Cụm Redis 7 (`redis-db`) | TCP 1433 (SQL TDS), TCP 6379 (Redis) | Lưu trữ bền vững toàn bộ 396 bảng nghiệp vụ tài chính vi mô; tài khoản `sa` / `Micro@31122020`; sao lưu tự động lúc 02:00 sáng hàng ngày vào `/data/backups/`. |

> [!NOTE]
> Chi tiết toàn bộ thông số hạ tầng máy chủ, cấu hình Docker Container, chuỗi kết nối CSDL và mô hình điều phối mạng được đặc tả tại [docs/deployment_infrastructure.md](file:///Users/micro/Source/erp/mifinace/docs/deployment_infrastructure.md).

---

## 2. KIẾN TRÚC PHÂN TẦNG VÀ CẤU TRÚC MÃ NGUỒN

### 2.1. Cấu trúc thư mục mã nguồn
Cấu trúc mã nguồn của hệ thống được quy hoạch theo mô hình phân tầng hướng dịch vụ:

```
NG.mFinance/
├── Build/                              # Cấu hình đóng gói và thư viện nhị phân xuất bản
│   ├── Build.Client/                   # Bản build môi trường phát triển cho Desktop Client
│   ├── Build.Server/                   # Bản build môi trường phát triển cho Backend Server
│   └── Build.ClientRelease/            # Bộ cài đặt phát hành Client (.msi / Setup)
├── Client/                             # Phân hệ phía người dùng (Presentation Layer)
│   └── 01.Presentation/
│       ├── Presentation.WPF/           # 35 Module giao diện WPF Desktop (XAML / MVVM / Code-behind)
│       ├── Presentation.AspNet/        # 3 Module Web Portal (MVC, WebForms, WebClient)
│       └── Presentation.Process/       # 39 Lớp Process trung gian gọi WCF Service Proxy
├── Server/                             # Phân hệ máy chủ nghiệp vụ (Backend Server)
│   ├── 01.Presentation/               # Công cụ quản trị máy chủ (DataMigration, Monitor)
│   ├── 02.Hosts/                       # Vỏ bọc máy chủ (Hosts.WebHost, Hosts.WinHost, Hosts.Startup)
│   ├── 03.Communication/               # Tầng giao tiếp WCF (Contracts, Messages, 36 Services)
│   ├── 04.Business/                    # Tầng nghiệp vụ lõi (39 Business Services chuyên biệt)
│   └── 05.DataAccess/                  # Tầng truy xuất dữ liệu (DataModel.ADO, EF, 31 Data Services)
├── Utilities/                          # Tiện ích dùng chung toàn hệ thống
│   ├── Utilities.Common/               # Thư viện dùng chung (Bảo mật, Hằng số, Log, Chuyển đổi dữ liệu)
│   └── Utilities.ZATools/              # Công cụ hỗ trợ phát triển và sinh mã tự động
├── Libraries/                          # Các tệp thư viện bên thứ 3 (Telerik, Crystal Reports, Quartz)
└── Documents/                          # Tài liệu và hình ảnh hướng dẫn
```

### 2.2. Giao tiếp và tích hợp dịch vụ

```mermaid
flowchart LR
    subgraph S_ORCHESTRATION ["TẦNG TRÌNH DIỄN & ĐIỀU PHỐI CLIENT PROXY"]
        direction TB
        WPF_GUI["Giao diện Desktop Client WPF<br/>• PresentationWPF.* (35 Modules)<br/>• Telerik Ribbon & DataGrid Controls"]
        WEB_GUI["Giao diện Web Portal MVC<br/>• PresentationAspNet.MVC / WebClient<br/>• Cổng tra cứu báo cáo & AutoUpdate"]
        PROC_PROXY["Tầng Điều phối Presentation.Process<br/>• 39 Process Proxy Classes<br/>• TinDungProcess, KeToanProcess,...<br/>• Cấu hình Buffer 2GB Serialization"]
        WPF_GUI --> PROC_PROXY
        WEB_GUI --> PROC_PROXY
    end

    subgraph S_SERVICES ["TẦNG MÁY CHỦ DỊCH VỤ & HỆ THỐNG NGOÀI"]
        direction TB
        WCF_COMM["Cụm Dịch vụ WCF Communication<br/>• 35 Endpoints .svc trên Hosts.WebHost<br/>• Hosts.WinHost Windows Service Standalone"]
        CORE_BIZ["Động cơ Nghiệp vụ BusinessServices<br/>• 39 Modules xử lý quy tắc tài chính<br/>• Lập lịch trả nợ & Phân loại nợ 5 nhóm"]
        DAL_SVC["Tầng Truy cập Dữ liệu DataServices<br/>• DataModel.ADO (Stored Procedures)<br/>• DataModel.EntityFramework (ORM Models)"]
        EXT_SMS["Cổng Tin nhắn SMS Gateway<br/>• Modem GSM kết nối qua COM Port<br/>• Tự động gửi tin nhắn nhắc nợ"]
        EXT_RPT["Động cơ Báo cáo & Kết xuất File<br/>• Crystal Reports & FarPoint Spread<br/>• Xuất bản Excel & Báo cáo NHNN"]
        
        WCF_COMM --> CORE_BIZ
        CORE_BIZ --> DAL_SVC
        CORE_BIZ --> EXT_SMS
        CORE_BIZ --> EXT_RPT
    end

    PROC_PROXY -->|"1. WCF BasicHttp / NetTcp"| WCF_COMM
    DAL_SVC -->|"2. TDS SQL Port 1433"| DB_SERVER[("Cơ sở Dữ liệu<br/>Microsoft SQL Server")]
```

---

## 3. CÂY PHÂN RÃ CHỨC NĂNG HỆ THỐNG

```mermaid
%%{init: {'flowchart': {'nodeSpacing': 8, 'rankSpacing': 140, 'padding': 3, 'curve': 'basis'}}}%%
flowchart LR
    ROOT["HỆ THỐNG TÀI CHÍNH VI MÔ NG.mFinance"]:::cLevel0

    %% TẦNG 1: CÁC PHÂN HỆ CỐT LÕI (ĐỒNG BỘ ĐỘ DÀI KÝ TỰ ĐỂ CĂN DÓNG LỀ TRÁI)
    ROOT --> MOD1["1. PHÂN HỆ TÍN DỤNG VI MÔ"]:::cLevel1
    ROOT --> MOD2["2. PHÂN HỆ HUY ĐỘNG VỐN"]:::cLevel1
    ROOT --> MOD3["3. PHÂN HỆ KẾ TOÁN SỔ CÁI"]:::cLevel1
    ROOT --> MOD4["4. PHÂN HỆ NGÂN QUỸ TIỀN"]:::cLevel1
    ROOT --> MOD5["5. PHÂN HỆ KHÁCH HÀNG CỤM"]:::cLevel1
    ROOT --> MOD6["6. PHÂN HỆ TÀI SẢN ĐẢM BẢO"]:::cLevel1
    ROOT --> MOD7["7. PHÂN HỆ BẢO HIỂM TƯƠNG"]:::cLevel1
    ROOT --> MOD8["8. PHÂN HỆ BÁO CÁO DỮ LIỆU"]:::cLevel1
    ROOT --> MOD9["9. PHÂN HỆ QUẢN TRỊ TÁC VỤ"]:::cLevel1

    %% TẦNG 2: PHÂN RÃ CHỨC NĂNG CON ĐỘC LẬP
    MOD1 --> F1_1["1.1. Thẩm định & Hồ sơ vay"]:::cLevel2
    MOD1 --> F1_2["1.2. Hợp đồng & Khế ước"]:::cLevel2
    MOD1 --> F1_3["1.3. Lập lịch thu phát vốn"]:::cLevel2
    MOD1 --> F1_4["1.4. Phân loại nợ 5 nhóm"]:::cLevel2
    MOD1 --> F1_5["1.5. Trích lập dự phòng RR"]:::cLevel2
    MOD1 --> F1_6["1.6. Xử lý nợ & Tất toán"]:::cLevel2

    MOD2 --> F2_1["2.1. Tiết kiệm có kỳ hạn"]:::cLevel2
    MOD2 --> F2_2["2.2. Tiết kiệm bậc thang"]:::cLevel2
    MOD2 --> F2_3["2.3. Tính lãi & Nhập gốc"]:::cLevel2
    MOD2 --> F2_4["2.4. Trích xuất sổ phụ GD"]:::cLevel2
    MOD2 --> F2_5["2.5. Chỉ thị đáo hạn & Rút"]:::cLevel2

    MOD3 --> F3_1["3.1. Tài khoản nội ngoại bảng"]:::cLevel2
    MOD3 --> F3_2["3.2. Phiếu thu chi tiền mặt"]:::cLevel2
    MOD3 --> F3_3["3.3. Phiếu kế toán tổng hợp"]:::cLevel2
    MOD3 --> F3_4["3.4. Bút toán kết chuyển"]:::cLevel2
    MOD3 --> F3_5["3.5. Đóng sổ cuối ngày COB"]:::cLevel2

    MOD4 --> F4_1["4.1. Hạn mức tồn quỹ két"]:::cLevel2
    MOD4 --> F4_2["4.2. Quỹ lưu động cụm tổ"]:::cLevel2
    MOD4 --> F4_3["4.3. Kiểm kê quỹ tiền mặt"]:::cLevel2
    MOD4 --> F4_4["4.4. Điều chuyển quỹ nội bộ"]:::cLevel2

    MOD5 --> F5_1["5.1. Hồ sơ thành viên vi mô"]:::cLevel2
    MOD5 --> F5_2["5.2. Chấm điểm hộ nghèo"]:::cLevel2
    MOD5 --> F5_3["5.3. Mạng lưới Vùng Miền Cụm"]:::cLevel2
    MOD5 --> F5_4["5.4. Quản lý Nhóm vay vốn"]:::cLevel2

    MOD6 --> F6_1["6.1. Định giá tài sản bảo đảm"]:::cLevel2
    MOD6 --> F6_2["6.2. Phong tỏa giải tỏa TS"]:::cLevel2
    MOD6 --> F6_3["6.3. Danh mục tài sản nội bộ"]:::cLevel2
    MOD6 --> F6_4["6.4. Tự động tính khấu hao"]:::cLevel2

    MOD7 --> F7_1["7.1. Quỹ tương hỗ vi mô"]:::cLevel2
    MOD7 --> F7_2["7.2. Tiếp nhận hồ sơ rủi ro"]:::cLevel2
    MOD7 --> F7_3["7.3. Phê duyệt chi trả trợ cấp"]:::cLevel2

    MOD8 --> F8_1["8.1. Báo cáo thống kê FRD"]:::cLevel2
    MOD8 --> F8_2["8.2. Cân đối kế toán tài chính"]:::cLevel2
    MOD8 --> F8_3["8.3. Đối soát sao kê dòng tiền"]:::cLevel2
    MOD8 --> F8_4["8.4. Xuất Crystal & Excel"]:::cLevel2

    MOD9 --> F9_1["9.1. Phân quyền RBAC 5 cấp"]:::cLevel2
    MOD9 --> F9_2["9.2. Lập lịch tác vụ Quartz"]:::cLevel2
    MOD9 --> F9_3["9.3. Cổng SMS Gateway GSM"]:::cLevel2
    MOD9 --> F9_4["9.4. Nhật ký kiểm toán 24/7"]:::cLevel2

    %% KHAI BÁO CLASS STYLES
    classDef cLevel0 fill:#1e3a8a,stroke:#1e40af,stroke-width:2px,color:#ffffff,font-size:12px,font-weight:bold,padding:6px 16px;
    classDef cLevel1 fill:#eff6ff,stroke:#3b82f6,stroke-width:1.5px,color:#1e3a8a,font-size:11px,font-weight:bold,padding:5px 14px;
    classDef cLevel2 fill:#f8fafc,stroke:#94a3b8,stroke-width:1px,color:#0f172a,font-size:10px,padding:4px 10px;
```

---

## 4. MA TRẬN ĐẶC TẢ PHÂN HỆ NGHIỆP VỤ

| Mã Phân hệ | Tên Phân hệ Nghiệp vụ | Chức năng cốt lõi trong Source Code |
| :--- | :--- | :--- |
| **TDVM / TDTT / TDTD** | Tín dụng Vi mô & Tiêu dùng | Quản lý quy trình tín dụng khép kín: Thẩm định hồ sơ vay → Phê duyệt hạn mức → Lập hợp đồng tín dụng → Giải ngân từng lần theo khế ước → Lập lịch thu nợ theo cụm/nhóm khách hàng → Tạm ứng và hoàn ứng giải ngân lưu động → Thu nợ gốc lãi định kỳ (đơn vị tiền tệ MMK) → Xử lý gia hạn nợ, chuyển nhóm nợ quá hạn (Nhóm 1 đến Nhóm 5) → Trích lập dự phòng rủi ro theo quy chuẩn FRD Myanmar → Xử lý tài sản xiết nợ và tất toán hợp đồng. |
| **HDVO** | Huy động Tiết kiệm | Quản lý sản phẩm tiền gửi tiết kiệm tự nguyện, tiết kiệm bắt buộc của thành viên vay vốn; tính toán lãi suất cố định, thả nổi, bậc thang; trả lãi đầu kỳ, cuối kỳ, định kỳ hoặc lãi nhập gốc; in sổ tiết kiệm, trích xuất sổ phụ và xử lý tất toán/rút trước hạn bằng đồng MMK. |
| **GDKT** | Kế toán Giao dịch | Hạch toán kép theo bảng hệ thống tài khoản kế toán tổ chức tài chính vi mô Myanmar; lập và duyệt các chứng từ thu tiền, chi tiền, ủy nhiệm chi, chứng từ kế toán tổng hợp; hạch toán phân bổ doanh thu, phân bổ chi phí; thực hiện quy trình đóng sổ và khóa sổ cuối ngày (COB). |
| **KHTV** | Khách hàng & Thành viên | Quản lý hồ sơ định danh thành viên qua Thẻ căn cước công dân Myanmar (NRC Card dạng `[Region]/[Township](N)[Number]`); cấu trúc mạng lưới quản lý địa bàn theo 4 cấp (Region/State → District → Township / Branch → Center / Village Track / Nhóm vay vốn); chấm điểm hộ nghèo qua các tiêu chí nhà ở (mái, tường, nền, sàn, nguồn nước, ánh sáng). |
| **NQUY** | Quản lý Ngân quỹ | Quản lý hạn mức tồn quỹ tiền mặt MMK tại két, quỹ của giao dịch viên tại quầy, quỹ của cán bộ tín dụng đi thu tiền lưu động ngoài địa bàn; điều chuyển vốn giữa các phòng giao dịch; kiểm kê và đối đối quỹ cuối ngày. |
| **TSDB** | Tài sản Bảo đảm | Đăng ký danh mục tài sản bảo đảm (bất động sản, phương tiện, giấy tờ có giá, tín chấp cụm tổ); thẩm định và phê duyệt giá trị định giá; phong tỏa, giải tỏa tài sản khi tất toán khế ước. |
| **BHTH** | Bảo hiểm Tương hỗ | Quản lý quỹ tương hỗ cộng đồng cho thành viên vay vốn vi mô; tiếp nhận và phê duyệt hồ sơ yêu cầu chi trả trợ cấp khi khách hàng gặp rủi ro tai nạn, thương tật hoặc thiên tai. |
| **QLTS** | Quản lý Tài sản Nội bộ | Quản lý danh mục tài sản cố định, công cụ dụng cụ của đơn vị; tự động tính khấu hao tài sản định kỳ hàng tháng; điều chuyển tài sản giữa các phòng ban và ghi nhận thanh lý. |
| **BaoCao / KTDL** | Báo cáo & Khai thác Dữ liệu | Xuất bản hệ thống báo cáo định kỳ theo mẫu chuẩn Cục Quản lý Tài chính Vi mô Myanmar (FRD) và Hiệp hội Tài chính Vi mô Myanmar (MMFA); báo cáo cân đối kế toán, báo cáo lưu chuyển tiền tệ, báo cáo phân tích chất lượng tín dụng; tích hợp Crystal Reports và xuất khẩu Excel. |
| **QTHT / Job / SMS** | Quản trị & Tác vụ Tự động | Phân quyền người dùng theo mô hình RBAC 5 cấp; kiểm soát phạm vi chi nhánh; điều phối tác vụ lập lịch Quartz.NET; cổng gửi tin nhắn SMS nhắc nợ qua modem GSM/Com Port (hỗ trợ bảng mã ký tự Myanmar/English). |

---

## 5. ĐÁNH GIÁ KỸ THUẬT VÀ NỢ CÔNG NGHỆ

### 5.1. Điểm mạnh hệ thống
1. **Kiến trúc phân lớp chuẩn mực:** Phân chia rạch ròi giữa Presentation, Process Proxy, WCF Host, Communication Service, Business Logic và Data Access giúp mã nguồn có tính tổ chức cao, dễ bảo trì theo từng nghiệp vụ riêng lẻ.
2. **Bao phủ toàn diện nghiệp vụ đặc thù:** Đã mô hình hóa đầy đủ các nghiệp vụ tài chính vi mô phức tạp (quản lý theo mô hình Cụm/Tổ, giải ngân lưu động, thu nợ theo tuần/tháng tại cơ sở, đánh giá hộ nghèo đa chiều, tương hỗ thành viên).
3. **Cơ chế truyền thông và xử lý dung lượng lớn:** Cấu hình Buffer 2GB và tuần tự hóa tùy biến giúp hệ thống xử lý mượt mà các bảng kê thu tiền hàng loạt mà không gặp lỗi nghẽn bộ nhớ.
4. **Hệ thống hằng số và danh mục chuẩn hóa:** Khai báo tập trung qua `DatabaseConstant` và `BusinessConstant`, giúp bảo đảm tính nhất quán cao trên toàn bộ các tầng ứng dụng.

### 5.2. Hạn chế và nợ kỹ thuật
1. **Ngăn xếp công nghệ đã cũ:** 
   * Xây dựng trên nền .NET Framework 4.0/4.5, không tận dụng được các cải tiến vượt bậc về hiệu năng, bộ nhớ và kiến trúc đa nền tảng của .NET 8 / .NET 9 LTS.
   * Công nghệ giao tiếp WCF hiện đã lỗi thời và không còn được Microsoft hỗ trợ native trên các nền tảng .NET hiện đại.
2. **Hạn chế về nền tảng giao diện người dùng:**
   * Ứng dụng phía Client phụ thuộc hoàn toàn vào hệ điều hành Windows (WPF Desktop App). Cán bộ tín dụng khi ra địa bàn thu tiền tại Cụm/Tổ phải mang máy tính xách tay, chưa có ứng dụng Mobile App (iOS / Android) gọn nhẹ để thu tiền và đồng bộ trực tuyến.
   * Giao diện Web ASP.NET MVC / WebForms hiện tại chỉ đóng vai trò thứ yếu, chưa phải là Single-Page Application hoàn chỉnh.
3. **Phụ thuộc vào các thư viện độc quyền và đã lỗi thời:**
   * Sử dụng các phiên bản cũ của Telerik, Infragistics, FarPoint Spread, Crystal Reports Engine và WPFToolkit.
   * Chuỗi bản quyền tệp tin Aspose được nhúng trực tiếp trong mã nguồn (`ApplicationConstant.asposeWordLic`).
4. **Vấn đề an toàn thông tin và bảo mật cấu hình:**
   * Thuật toán mã hóa cấu hình hệ thống đang sử dụng chuẩn DES cổ điển với chuỗi khóa tĩnh (`!=Q|A'Z?`), tiềm ẩn rủi ro giải mã nếu lộ mã nguồn.
   * Các chuỗi kết nối cơ sở dữ liệu trong một số tệp cấu hình `App.config` / `Web.config` còn lưu trữ thông tin tài khoản truy cập dạng văn bản rõ hoặc chưa được tích hợp hệ thống quản lý khóa tập trung.

---

## 6. LỘ TRÌNH HIỆN ĐẠI HÓA HỆ THỐNG

```mermaid
flowchart LR
    subgraph S_MOD_LEFT ["1. BACKEND HIỆN ĐẠI & HẠ TẦNG CLOUD"]
        direction TB
        MOD_BE["Chuyển đổi Backend sang .NET 8 LTS / Spring Boot<br/>• Thay thế WCF bằng RESTful API chuẩn OpenAPI & gRPC<br/>• Kiến trúc Clean Architecture / Domain-Driven Design<br/>• Triển khai Docker Container & Kubernetes Auto-scaling"]
        MOD_DATA["Nâng cấp Hạ tầng Dữ liệu & Bộ nhớ đệm<br/>• Cụm Redis Distributed Cache Cluster xử lý phiên & Lock<br/>• Phân tách Đọc/Ghi CSDL theo mô hình CQRS Pattern<br/>• Mã hóa trong suốt TDE & AES-256 cho dữ liệu nhạy cảm"]
        MOD_BE --> MOD_DATA
    end

    subgraph S_MOD_RIGHT ["2. GIAO DIỆN ĐA KÊNH & SỐ HÓA NGHIỆP VỤ"]
        direction TB
        MOD_WEB["Web Portal Doanh nghiệp Hiện đại (Next.js / React)<br/>• Giao diện Responsive hỗ trợ Light/Dark Theme<br/>• Tương thích 100% mọi trình duyệt Web hiện đại<br/>• Quản lý đa ngôn ngữ i18n đồng bộ 5 thứ tiếng"]
        MOD_MOB["Mobile App Cán bộ Tín dụng (Flutter / React Native)<br/>• Thu nợ lưu động ngoại tuyến (Offline-First Sync Engine)<br/>• Tích hợp định vị GPS & In phiếu thu Bluetooth cầm tay<br/>• Nhận diện khuôn mặt eKYC, MMQR & Ký số điện tử"]
        MOD_WEB --> MOD_MOB
    end

    S_MOD_LEFT ==> S_MOD_RIGHT
```

### 6.1. Kế hoạch hành động
1. **Hiện đại hóa tầng Backend Dịch vụ:**
   * Tái cấu trúc từ WCF sang **RESTful API chuẩn OpenAPI/Swagger** hoặc **gRPC** hiệu năng cao trên nền **.NET 8 LTS**.
   * Đóng gói Backend thành các Container Docker độc lập, triển khai điều phối trên Kubernetes giúp hệ thống tự động mở rộng khi tải cao vào các ngày cao điểm đóng sổ.
2. **Phát triển ứng dụng di động cho Cán bộ Tín dụng (Field Collection App):**
   * Xây dựng Mobile App chạy trên điện thoại di động thông minh (iOS / Android) với tính năng hoạt động ngoại tuyến (Offline-first): Cán bộ tín dụng có thể thu nợ tại vùng sâu vùng xa không có sóng Internet và tự động đồng bộ dữ liệu về máy chủ khi có kết nối mạng.
   * Tích hợp thanh toán số qua **MMQR / KBZPay / WavePay** và in biên lai thu tiền qua máy in nhiệt cầm tay Bluetooth.
3. **Nâng cấp Hệ thống An toàn Thông tin:**
   * Thay thế hoàn toàn mã hóa DES bằng **AES-256** và truyền thông qua kênh bảo mật **TLS 1.3**.
   * Áp dụng cơ chế xác thực phiên hiện đại bằng **OAuth 2.0 / OpenID Connect** kết hợp **Stateless JWT Token** và quản lý phiên trên **Redis Cache Cluster**.
   * Quản lý thông tin bảo mật và chuỗi kết nối qua **HashiCorp Vault** hoặc **Azure Key Vault**.
4. **Tích hợp tính năng Số hóa Tiên tiến:**
   * Tích hợp **eKYC** xác thực danh tính khách hàng qua Thẻ NRC Myanmar và nhận diện khuôn mặt sinh trắc học.
   * Tích hợp **Smart OTP** và **Ký số hợp đồng điện tử**, giảm thiểu hoàn toàn việc in ấn và lưu trữ hồ sơ giấy tờ truyền thống.
