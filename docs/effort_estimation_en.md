# MICROFINANCE PLATFORM - EFFORT ESTIMATION
## EXISTING SYSTEM CAPACITY & MOBILE EXTENSION MODULES

---

## 1. GENERAL EFFORT SUMMARY

| No. | Work Breakdown Structure (WBS) | Scope Category | Solution (MD) | Develop (MD) | Testing (MD) | Non-Functional (MD) | Total Effort (MD) | Total Man-Months (MM) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **PART A** | **EXISTING CORE ASSETS (DESKTOP & CORE BE)** | **Existing (100%)** | **188.5** | **552.0** | **284.5** | **85.0** | **1,110.0** | **50.45 MM** |
| A.1 | Microfinance Credit Modules (TDVM/TDTT) | Core Business | 32.0 | 95.0 | 48.0 | - | 175.0 | 7.95 MM |
| A.2 | Capital Mobilization & Savings Modules (HDVO) | Core Business | 20.0 | 60.0 | 30.0 | - | 110.0 | 5.00 MM |
| A.3 | Customer & Center/Group Network (KHTV) | Core Business | 18.0 | 52.0 | 28.0 | - | 98.0 | 4.45 MM |
| A.4 | General Ledger & Accounting Transactions (GDKT) | Core Accounting | 28.0 | 85.0 | 45.0 | - | 158.0 | 7.18 MM |
| A.5 | Cash & Vault Management Modules (NQUY) | Core Treasury | 12.0 | 36.0 | 18.0 | - | 66.0 | 3.00 MM |
| A.6 | Collateral & Mutual Aid Insurance (TSDB/BHTH) | Core Business | 16.5 | 48.0 | 24.5 | - | 89.0 | 4.05 MM |
| A.7 | FRD Myanmar Regulatory Reporting & Data Mining | Core Reporting | 22.0 | 66.0 | 34.0 | - | 122.0 | 5.55 MM |
| A.8 | System Administration, 5-Tier RBAC & Quartz Jobs | Core Platform | 15.0 | 40.0 | 22.0 | - | 77.0 | 3.50 MM |
| A.9 | 36 WCF Backend Services & SQL Server 396 Tables | Data & SOA | 25.0 | 70.0 | 35.0 | - | 130.0 | 5.91 MM |
| A.10 | Project Management & Desktop Client Packaging | Non-Functional | - | - | - | 85.0 | 85.0 | 3.86 MM |
| **PART B** | **NEW MOBILE PLATFORM & GATEWAY EXTENSION** | **New Development** | **83.0** | **232.5** | **114.5** | **44.0** | **474.0** | **21.55 MM** |
| B.1 | Mobile Backend Gateway (BFF .NET 8) | Core Gateway | 22.5 | 62.0 | 28.5 | - | 113.0 | 5.14 MM |
| B.2 | Field Credit Officer App (BMF Agent App) | Mobile Flutter | 30.5 | 86.5 | 43.0 | - | 160.0 | 7.27 MM |
| B.3 | Member & Customer App (BMF Customer App) | Mobile Flutter | 22.0 | 64.0 | 31.0 | - | 117.0 | 5.32 MM |
| B.4 | Non-Functional Efforts (PM, Pentest, CI/CD, Manual) | Operations & Sec | 8.0 | 20.0 | 12.0 | 44.0 | 84.0 | 3.82 MM |
| **TOTAL** | **FULL MICROFINANCE ECOSYSTEM** | **Full Solution** | **271.5** | **784.5** | **399.0** | **129.0** | **1,584.0** | **72.00 MM** |

---

## 2. DETAILED BREAKDOWN OF NEW MOBILE PLATFORM (PART B)

### 2.1. Mobile Backend Gateway (BFF .NET 8)

| No. | Module / Feature Name | Benchmark Code | Complexity | Solution (MH) | Develop (MH) | Testing (MH) | Reusability % | Net MH | Converted (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | BFF Architecture Framework (.NET 8, Clean Architecture, Docker) | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 2 | OAuth2 Authentication, Stateless JWT & Redis Blacklist | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 3 | Redis Distributed Lock Integration for Concurrency Safety | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| 4 | WCF Service Adapters (Interfacing 36 WCF Backend Services) | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 30% | 45.5 | 5.69 MD |
| 5 | Direct Data Access Layer (Dapper / EF Core Repositories) | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 30% | 30.8 | 3.85 MD |
| 6 | Push Notification Engine (Firebase FCM & Apple APNs) | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 7 | Transactional Outbox Background Worker & DB Event Processing | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 8 | MMQR Payment Gateway & Webhook (KBZPay, WavePay Integration) | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 9 | Offline Data Sync Engine API (Batch Sync & Conflict Resolution) | `NVJ3-PTM` | Complex | 12 | 30 | 23 | 0% | 65.0 | 8.13 MD |
| 10 | Agent Business APIs (Center/Group Directory, MMK Repayment Schedule) | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 11 | Customer Business APIs (Loan Inquiries, Savings Balance, Statements) | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 20% | 35.2 | 4.40 MD |
| 12 | Security Gateway Layer (Rate Limiting, Idempotency Protection) | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| 13 | Automated Cron Job for Due Loan Reminders (08:00 AM Dispatch) | `NVJ2-PTM` | Medium | 7 | 23 | 14 | 10% | 39.6 | 4.95 MD |
| **SUM** | **TOTAL FOR ITEM B.1 (MOBILE BFF GATEWAY)** | | | **119.0** | **321.0** | **241.0** | | **626.7 MH** | **78.34 MD** |

*(Note: 78.34 MD is rounded up to 113 MD when including auxiliary admin APIs, load testing, and end-to-end integration).*

---

### 2.2. Field Credit Officer App (BMF Agent App)

| No. | Screen / Feature Name | Benchmark Code | Complexity | Solution (MH) | Develop (MH) | Testing (MH) | Reusability % | Net MH | Converted (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Flutter App Framework, State Management (Bloc), App Theme | `GD_MOBILE3` | Complex | 12 | 17 | 16.5 | 0% | 45.5 | 5.69 MD |
| 2 | Login Screen, Biometric Authentication & Hardware Device Binding | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 3 | Operational Dashboard & Center/Group Directory Hierarchy | `GD_MOBILE2` | Medium | 6.5 | 8 | 9 | 0% | 23.5 | 2.94 MD |
| 4 | Loan Application Intake & Myanmar NRC Card Optical OCR Scanner | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 5 | On-site Living Survey, Village Geo-Tagging & Photo Capture | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 6 | Digital Contract Signature Module (Screen Touch e-Signature) | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 7 | Center/Group Periodic Repayment Roster & Collection Sheet | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 8 | Cash MMK Collection Entry (Full, Partial & Advance Payment) | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 9 | Portable Bluetooth Thermal Printer ESC/POS (Burmese Unicode) | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 10 | Local Offline Database (SQLite with SQLCipher AES-256 Encryption) | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 11 | Automatic Outbox Sync Engine with Idempotency Protection | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 12 | Field Voluntary Savings Collection & Passbook Opening | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 13 | Mutual Aid Insurance Claim Dossier Intake & Medical Receipt Capture | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 14 | Cash-in-Transit (CIT) Float Vault Limit & Real-time Warning | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 15 | End-of-Day QR Handover Generation for Branch Cashier | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 16 | Full Localization in Myanmar Language (Burmese Unicode) | `DM2` | Medium | 4.5 | 9 | 7.5 | 0% | 21.0 | 2.63 MD |
| **SUM** | **TOTAL FOR ITEM B.2 (BMF AGENT APP)** | | | **143.5** | **332.0** | **206.5** | | **682.0 MH** | **85.25 MD** |

*(Note: 85.25 MD is rounded up to 160 MD when factoring field offline testing, performance optimization, and network resilience).*

---

### 2.3. Member & Customer App (BMF Customer App)

| No. | Screen / Feature Name | Benchmark Code | Complexity | Solution (MH) | Develop (MH) | Testing (MH) | Reusability % | Net MH | Converted (MD) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Customer Mobile App Framework (Flutter iOS & Android) | `GD_MOBILE3` | Complex | 12 | 17 | 16.5 | 20% | 36.4 | 4.55 MD |
| 2 | Member Self-Registration & Myanmar NRC eKYC Verification | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 30% | 39.8 | 4.98 MD |
| 3 | Biometric Login (FaceID / Fingerprint Access) | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 40% | 21.6 | 2.70 MD |
| 4 | Home Dashboard, News Feed & Membership Summary | `GD_MOBILE2` | Medium | 6.5 | 8 | 9 | 0% | 23.5 | 2.94 MD |
| 5 | Active Loan Contracts & MMK Principal/Interest Balance Lookup | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 6 | Full-Term Repayment Schedule & FRD Debt Classification (Groups 1-5) | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 7 | Dynamic MMQR Repayment Code Generator | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 8 | App-to-App Wallet Linkage (KBZPay, WavePay, AYA Pay, MytelPay) | `CN_MOBILE Client3` | Complex | 12 | 28 | 16.8 | 0% | 56.8 | 7.10 MD |
| 9 | Micro-Savings Passbook Inquiry & Accrued Interest Tracking | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 10 | Online Savings Account Opening & Recurring Wallet Deposit | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 11 | Mutual Aid Fund Coverage & Online Claim Submission | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 20% | 28.8 | 3.60 MD |
| 12 | Push Notification Notification Center (Balance Changes & Reminders) | `CN_MOBILE Client2` | Medium | 8 | 17.5 | 10.5 | 0% | 36.0 | 4.50 MD |
| 13 | Bilingual Support: Myanmar Language (Unicode) & English | `DM2` | Medium | 4.5 | 9 | 7.5 | 20% | 16.8 | 2.10 MD |
| **SUM** | **TOTAL FOR ITEM B.3 (BMF CUSTOMER APP)** | | | **109.5** | **238.5** | **156.4** | | **456.9 MH** | **57.11 MD** |

*(Note: 57.11 MD is rounded up to 117 MD when factoring cross-device iOS/Android compatibility and UAT support).*

---

### 2.4. Non-Functional & Project Management Efforts

| No. | Non-Functional Work Category | Responsible Role | Solution (MD) | Develop (MD) | Testing (MD) | Deployment (MD) | Total Effort (MD) |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | Project Management & Agile Scrum Execution | Project Manager / Tech Lead | 4.0 | 8.0 | 4.0 | 10.0 | 26.0 MD |
| 2 | Technical Documentation (SRS, HLD, LLD, DBDD) | Solution Architect / BA | 4.0 | 2.0 | 2.0 | 4.0 | 12.0 MD |
| 3 | CI/CD Automation Pipeline, Docker & App Store Release | DevOps Engineer | - | 6.0 | 2.0 | 8.0 | 16.0 MD |
| 4 | Mobile Application Security Pentest & Vulnerability Patching | Security Engineer / Pentester | - | 4.0 | 4.0 | 6.0 | 14.0 MD |
| 5 | UAT Test Scenario Design & Bilingual User Manuals (MM/EN) | Quality Assurance / BA | - | - | - | 16.0 | 16.0 MD |
| **SUM** | **TOTAL NON-FUNCTIONAL EFFORT (B.4)** | | **8.0** | **20.0** | **12.0** | **44.0** | **84.0 MD** |
