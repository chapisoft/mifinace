# HẠ TẦNG TRIỂN KHAI VÀ THÔNG SỐ DỊCH VỤ MICRO FINANCE

---

## 1. HẠ TẦNG MÁY CHỦ MICRO-SERVER

Hệ thống Micro Finance (NG.mFinance) được thiết lập và vận hành trên cụm máy chủ nội bộ chuyên trách `micro-server` đặt tại mạng nội bộ LAN, được công bố ra ngoài Internet thông qua Cổng chuyển tiếp bảo mật FRP Gateway (VPS Google Cloud) kết hợp Cloudflare SSL.

### 1.1. Cấu hình phần cứng
* **Tên máy chủ (Hostname):** `micro`
* **Địa chỉ mạng nội bộ LAN:** `192.168.1.200`
* **Hệ điều hành:** Ubuntu 22.04 LTS (Kernel Linux 5.15.0 x86_64)
* **Vi xử lý CPU:** 2 × Intel Xeon E5-2670 @ 2.60GHz (Tổng cộng 16 nhân / 32 luồng vật lý, tập lệnh SSE4.2 / AVX)
* **Bộ nhớ RAM:** 62 GB DDR3 ECC Registered (Khả dụng ~54 GB)
* **Card đồ họa GPU:** Inno3D / ZOTAC GeForce RTX 3060 12GB GDDR6 (3.584 nhân CUDA, 112 Tensor Cores Gen 3)
* **Ổ đĩa SSD Hệ điều hành (`sdb`):** 240 GB Enterprise SSD (Phân vùng Root `/` dung lượng 218 GB)
* **Ổ đĩa HDD Dữ liệu lớn (`sda`):** 4 TB SAS RAID (3.6 TB quản lý bằng LVM `vg_data`)

### 1.2. Phân vùng lưu trữ LVM

| Phân vùng LVM | Điểm gắn kết (Mount Point) | Dung lượng | Trách nhiệm chuyên trách đối với Micro Finance |
| :--- | :--- | :--- | :--- |
| `vg_data-lv_uc1_software` | `/data/uc1-software` | 787 GB | **Phần mềm & Cơ sở dữ liệu:** Chứa tệp nguồn ứng dụng WCF Micro Finance (`/data/uc1-software/apps/micro-finance/`), cấu hình Sub-Nginx UC1 và dữ liệu CSDL SQL Server 2017 (`mssql-db`). |
| `vg_data-lv_uc3_infra` | `/data/uc3-infra` | 492 GB | **Hạ tầng & Giám sát tập trung:** Chứa Docker Data-Root, Cổng chuyển tiếp FRP Client, Cụm thu thập nhật ký tập trung ELK (Elasticsearch, Logstash, Kibana) và Prometheus + Grafana. |
| `vg_data-lv_backups` | `/data/backups` | 295 GB | **Sao lưu dữ liệu tự động:** Lưu trữ bản sao lưu định kỳ hàng ngày của CSDL `NG-mFINA-BMF_20180402` và tệp cấu hình hệ thống. |

---

## 2. THÔNG SỐ DỊCH VỤ VÀ CSDL

```mermaid
%%{init: {'flowchart': {'nodeSpacing': 14, 'rankSpacing': 24, 'padding': 8}, 'themeVariables': {'fontSize': '13px', 'fontFamily': 'Inter, Arial, sans-serif'}}}%%
flowchart TD
    %% 1. TẦNG INTERNET & GATEWAY
    subgraph S_EXT ["1. TẦNG TRUY CẬP INTERNET & GATEWAY TRUNG GIAN"]
        direction LR
        USER_INET["Người dùng Internet & Cán bộ Tín dụng<br/>• Tên miền: https://mfina.microtec.vn<br/>• Quản trị SSH: ssh.microtec.vn (Cổng 65000)"]:::cClient ~~~ VPS_GW["Cổng chuyển tiếp FRP Gateway (VPS GCP 35.247.156.176)<br/>• Nginx Gateway tiếp nhận cổng 80/443 SSL<br/>• FRP Server chuyển tiếp cổng WCF & Web"]:::cExt
    end

    %% 2. TẦNG NGINX MASTER & ĐIỀU PHỐI NỘI BỘ
    subgraph S_DMZ ["2. TẦNG BIÊN AN NINH & NGINX GATEWAY (192.168.1.200)"]
        direction LR
        FRPC["FRP Client Service (Systemd)<br/>• Duy trì đường hầm bảo mật 2 chiều<br/>• Nhận luồng từ VPS chuyển về cổng nội bộ"]:::cDmz ~~~ NGINX_M["Nginx Master Gateway (Port 80/443)<br/>• Định tuyến tên miền mfina.microtec.vn<br/>• Chuyển tiếp tới Container WCF 1011"]:::cDmz
    end

    %% 3. TẦNG ỨNG DỤNG MICRO FINANCE VÀ CSDL
    subgraph S_CORE ["3. TẦNG ỨNG DỤNG NGHIỆP VỤ VÀ CƠ SỞ DỮ LIỆU NỘI BỘ"]
        direction TB
        subgraph APP_CONTAINER ["Cụm Ứng dụng Backend Micro Finance"]
            direction LR
            WCF_APP["Container: micro-finance-app<br/>• Cổng nội bộ: 127.0.0.1:1011<br/>• Mono XSP4 Server / .NET 4.0 WCF<br/>• Thư mục: /data/uc1-software/apps/micro-finance/"]:::cCore ~~~ REDIS_SVC["Container: redis-db (Redis 7)<br/>• Cổng nội bộ: 127.0.0.1:6379<br/>• Bộ nhớ đệm Token & Distributed Lock"]:::cCore
        end

        subgraph DB_CONTAINER ["Cơ sở Dữ liệu SQL Server 2017"]
            direction LR
            MSSQL_SVC["Container: mssql-db (SQL Server 2017)<br/>• Cổng nội bộ: 127.0.0.1:1433<br/>• Cơ sở dữ liệu: NG-mFINA-BMF_20180402 (396 Bảng)<br/>• Tài khoản: sa / Mật khẩu: Micro@31122020"]:::cDb
        end

        APP_CONTAINER --> DB_CONTAINER
    end

    %% 4. TẦNG GIÁM SÁT VÀ SAO LƯU TẬP TRUNG
    subgraph S_MONITOR ["4. TẦNG GIÁM SÁT VÀ SAO LƯU TẬP TRUNG"]
        direction LR
        ELK_MON["Cụm Quản lý Log ELK<br/>• Elasticsearch (9200) & Kibana (5601)<br/>• Thu thập nhật ký giao dịch tài chính"]:::cOam ~~~ PROM_MON["Cụm Giám sát Hiệu năng APM<br/>• Prometheus (9090) & Grafana (3003)<br/>• Theo dõi tải CPU, RAM, Connection Pool"]:::cOam ~~~ BAK_SYS["Hệ thống Sao lưu Tự động<br/>• Script: /data/backups/backup_all_db.sh<br/>• Sao lưu định kỳ 02:00 sáng hàng ngày"]:::cOam
    end

    %% KẾT NỐI LUỒNG
    USER_INET --> VPS_GW
    VPS_GW <-->|Đường hầm FRP bảo mật| FRPC
    FRPC --> NGINX_M
    NGINX_M --> WCF_APP
    WCF_APP -->|"TDS Port 1433"| MSSQL_SVC
    WCF_APP -.->|"Ghi log ECS JSON"| ELK_MON
    MSSQL_SVC -.->|"Sao lưu tự động"| BAK_SYS

    %% KHAI BÁO CLASS STYLES
    classDef cClient fill:#e8f4fd,stroke:#2b6cb0,stroke-width:1.5px,color:#1a365d;
    classDef cExt fill:#f1f5f9,stroke:#475569,stroke-width:1.5px,color:#0f172a;
    classDef cDmz fill:#fef3c7,stroke:#d97706,stroke-width:1.5px,color:#78350f;
    classDef cCore fill:#ecfdf5,stroke:#059669,stroke-width:1.5px,color:#064e3b;
    classDef cOam fill:#eff6ff,stroke:#3b82f6,stroke-width:1.5px,color:#1e3a8a;
    classDef cDb fill:#f5f3ff,stroke:#7c3aed,stroke-width:1.5px,color:#4c1d95;
```

### 2.1. Thông số kỹ thuật dịch vụ

| Hạng mục | Thông số cấu hình thực tế | Ý nghĩa & Vai trò vận hành |
| :--- | :--- | :--- |
| **Tên Dịch vụ** | `micro-finance-app` | Dịch vụ máy chủ WCF SOAP Backend của hệ thống Micro Finance. |
| **Môi trường thực thi** | Docker Container | Khởi chạy trên môi trường Docker Linux qua Mono XSP4 Server (.NET Framework 4.0). |
| **Thư mục ứng dụng** | `/data/uc1-software/apps/micro-finance/` | Chứa mã nguồn biên dịch nhị phân và các tệp cấu hình WCF Services (.svc). |
| **Cổng dịch vụ nội bộ** | `127.0.0.1:1011` | Cổng HTTP tiếp nhận yêu cầu từ Nginx Master Gateway. |
| **Tên miền truy cập Public** | `https://mfina.microtec.vn/` | Tên miền dịch vụ công bố ra ngoài qua Cloudflare và Cổng FRP Gateway VPS. |
| **Cơ sở dữ liệu liên kết** | `NG-mFINA-BMF_20180402` | Cơ sở dữ liệu tài chính vi mô chuẩn với **396 bảng nghiệp vụ**. |
| **Hệ quản trị CSDL** | Microsoft SQL Server 2017 (`mssql-db`) | Container SQL Server 2017 trên Docker (`127.0.0.1:1433`). |
| **Tài khoản quản trị CSDL** | `sa` | Tài khoản kết nối cơ sở dữ liệu. |
| **Mật khẩu chuẩn hóa** | `Micro@31122020` | Mật khẩu truy cập hệ thống chuẩn doanh nghiệp. |
| **Chuỗi kết nối JDBC** | `jdbc:sqlserver://127.0.0.1:1433;databaseName=NG-mFINA-BMF_20180402;encrypt=false` | Chuỗi kết nối từ các ứng dụng Java / Dịch vụ trung gian. |
| **Chuỗi kết nối ADO.NET** | `Data Source=127.0.0.1,1433;Initial Catalog=NG-mFINA-BMF_20180402;User ID=sa;Password=Micro@31122020;MultipleActiveResultSets=True` | Chuỗi kết nối chuẩn cho các thành phần .NET Backend. |
| **Bộ nhớ đệm Redis** | `redis-db` (`127.0.0.1:6379`, DB `0`) | Bộ nhớ đệm phân tán quản lý phiên đăng nhập và khóa phân tán Distributed Locks. |

---

## 3. ĐIỀU PHỐI MẠNG VÀ TÊN MIỀN

Toàn bộ dịch vụ cơ sở dữ liệu và ứng dụng nghiệp vụ được thiết lập theo nguyên tắc **Zero-Public (Không mở cổng CSDL trực tiếp ra ngoài Internet)**:
1. **Truy cập từ Internet:**
   * Khách hàng và cán bộ truy cập vào địa chỉ `https://mfina.microtec.vn/` (Cổng 443 SSL).
   * Yêu cầu đi qua CDN Cloudflare → Cổng VPS FRP Gateway (`35.247.156.176`).
   * FRP Server trên VPS chuyển tiếp lưu lượng qua đường hầm ngược (Reverse Tunnel) an toàn vào máy chủ nội bộ `micro-server` (`192.168.1.200`).
2. **Xử lý tại Máy chủ Nội bộ:**
   * Nginx Master Gateway tại máy chủ tiếp nhận luồng từ FRP Client và chuyển hướng vào Container `micro-finance-app` (Cổng `1011`).
   * Ứng dụng WCF Backend kết nối nội bộ tới CSDL SQL Server 2017 (`mssql-db:1433`) và Redis (`redis-db:6379`) trong cùng mạng Docker `databases_default`.
3. **Quản trị Máy chủ từ xa:**
   * Quản trị viên kết nối SSH bảo mật qua địa chỉ: `ssh -p 65000 root@35.247.156.176` hoặc `ssh -p 65000 adev@ssh.microtec.vn`.

---

## 4. VẬN HÀNH, GIÁM SÁT VÀ SAO LƯU

### 4.1. Giám sát tập trung
Dịch vụ Micro Finance được tích hợp vào hệ thống giám sát tập trung đặt tại `/data/uc3-infra/monitoring/`:
* **Quản trị nhật ký giao dịch qua ELK:** Nhật ký kiểm toán và vết giao dịch tài chính được đồng bộ về cụm Elasticsearch (`127.0.0.1:9200`) và trực quan hóa qua Kibana Dashboard (`https://kibana.microtec.vn/`).
* **Giám sát hiệu năng APM qua Prometheus & Grafana:** Thu thập các chỉ số thời gian thực về CPU, RAM, số lượng luồng, thời gian phản hồi API và trạng thái Connection Pool CSDL hiển thị trên Grafana Dashboard (`https://monitor.microtec.vn/`).
* **Cảnh báo sự cố:** Tích hợp Alertmanager (`127.0.0.1:9093`) tự động gửi cảnh báo khẩn cấp qua Telegram Bot khi có sự cố nghẽn kết nối CSDL hoặc gián đoạn dịch vụ.

### 4.2. Sao lưu dữ liệu tự động
* **Kịch bản thực thi:** `/data/backups/backup_all_db.sh`
* **Lịch biểu Crontab:** `0 2 * * *` (Tự động kích hoạt lúc **02:00 sáng hàng ngày**).
* **Quy trình sao lưu:**
  1. Trích xuất bản sao lưu đầy đủ của CSDL `NG-mFINA-BMF_20180402` từ SQL Server.
  2. Kích hoạt sao lưu snapshot `dump.rdb` của Redis hệ thống.
  3. Đóng gói nén toàn bộ tệp cấu hình ứng dụng, tệp `.env` và cấu hình Nginx thành tệp nén `.tar.gz`.
  4. Tự động dọn dẹp các bản sao lưu cũ vượt quá **30 ngày** trên phân vùng `/data/backups/` để tối ưu dung lượng đĩa cứng.
