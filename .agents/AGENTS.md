# QUY TẮC DỰ ÁN MICRO FINANCE (ERP PLATFORM) - AGENTS RUNBOOK

## 1. NGUYÊN TẮC TOÀN CỤC BẮT BUỘC
- **Ngôn ngữ:** Sử dụng tiếng Việt kỹ thuật chuẩn mực, trong sáng, mạch lạc. Tuyệt đối không chèn tiếng Anh đệm song ngữ trong ngoặc đơn. Giữ nguyên 100% các thuật ngữ kỹ thuật chuyên ngành chuẩn quốc tế (Engine, Framework, Middleware, FIFO, LIFO, Outbox Pattern, ShedLock, Circuit Breaker, Redis, Kafka, PostgreSQL, Oracle, Docker, Kubernetes, RESTful API, gRPC, RBAC, i18n,...).
- **Trực quan & Định dạng:** Không dùng icon/emoji tràn lan. Sử dụng ký tự Unicode thuần túy thay cho công thức LaTeX chứa dấu `$`. Vẽ sơ đồ Mermaid LR 2 cột chuẩn 4:3.
- **Tiến độ 3 tầng độc lập:** Tầng 1 (Mã nguồn nội bộ 60%), Tầng 2 (Tích hợp thực tế 20%), Tầng 3 (Phi chức năng & Vận hành 20%).

## 2. NGUYÊN TẮC CỐT LÕI BẮT BUỘC TRONG LẬP TRÌNH & TỔ CHỨC CODE
- **Cấu trúc thư mục chuẩn `src/` (Mã nguồn & CSDL):**
  - Toàn bộ mã nguồn phát triển (Backend, Frontend, Mobile) và kịch bản CSDL (DDL/DML migrations) **BẮT BUỘC phải đặt trong thư mục `src/`** (ví dụ: `src/backend/mobile-bff-gateway/`, `src/db/migrations/`, `src/mobile/`,...).
  - Tuyệt đối **CẤM** tạo thư mục code hoặc db rời rạc ngoài thư mục gốc.
- **100% Enum-Driven & Zero-Hardcode:**
  - Khai báo và sử dụng 100% Enum cho toàn bộ mã trạng thái (Status), phân loại (Type), vai trò (Role), phương thức (Method), nền tảng (Platform), mã lỗi (ErrorCode).
  - Tuyệt đối **CẤM** dùng chuỗi tự do (String literal) để gán hoặc so sánh logic (cấm `"SUCCESS"`, `"UP"`, `"ACTIVE"`, `"ADMIN"`, `"IOS"`,...).
- **Zero Fake Default Values & No Mock Data (Không gán giá trị mặc định giả lập):**
  - Đối tượng Entity, DTO, Request, Response, Form State: Tuyệt đối **CẤM** gán cứng các giá trị mặc định giả lập ngầm (cấm `@Builder.Default` gán dữ liệu ngầm không kiểm soát).
  - Dữ liệu tài chính và nghiệp vụ bắt buộc phải lấy 100% từ request thực tế hoặc truy vấn CSDL thật; nếu chưa có dữ liệu thì để rỗng (`null`, `""`, `[]`).
- **100% i18n & Phân giải đa ngôn ngữ qua Message Bundle:**
  - Toàn bộ thông điệp, nhãn trường, lỗi validation, thông báo nghiệp vụ và lỗi RFC 7807 Problem Details phải được quản lý tập trung qua hệ thống đa ngôn ngữ (`messages_*.properties` ở Backend và file JSON ở Frontend).
  - Bean Validation **BẮT BUỘC** dùng key template dạng `{validation...}` để tự động phân giải theo `Accept-Language` của Client.
  - Phân giải thông điệp qua `I18nService` / `MessageSource`, cấm hardcode câu chữ tiếng Việt hay tiếng Anh tự do trong Controller, Service, ExceptionHandler.
- **Zero Vietnamese in Technical Logs (100% Log tiếng Anh kỹ thuật):**
  - 100% thông điệp log (`log.info`, `log.warn`, `log.error`, `log.debug`) ở Backend, Frontend, Mobile bắt buộc phải viết bằng tiếng Anh kỹ thuật có cấu trúc, ngữ cảnh rõ ràng và đính kèm `traceId` (MDC). Tuyệt đối không log tiếng Việt.
- **Concurrency Data Integrity (Toàn vẹn dữ liệu đồng thời):**
  - Bắt buộc áp dụng Distributed Lock (Redis/Redisson) và Database Isolation Level cho các giao dịch tài chính (giải ngân, tính lãi, trích nợ, thanh toán, tất toán).
- **Phòng vệ an ninh 5 nguyên tắc (Security Defense):**
  - Default Deny 100% luồng dữ liệu (chống IDOR), Stateless Cache Persistence trên Redis, Action-Gate Defense-in-Depth, Bằng chứng thực chứng Hard Evidence or Zero, Sửa lỗi nhất quán toàn cục.

## 3. DANH MỤC QUY CHUẨN RULES VÀ KỸ NĂNG SKILLS CỦA HỆ THỐNG
- **Tài liệu Yêu cầu Phần mềm (SRS):** Quy chuẩn [.agents/rules/srs_authoring_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/srs_authoring_rules.md) | Kỹ năng `srs-authoring` tại [.agents/skills/srs-authoring/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/srs-authoring/SKILL.md).
- **Thiết kế Tổng thể (HLD):** Quy chuẩn [.agents/rules/hld_authoring_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/hld_authoring_rules.md) | Kỹ năng `hld-writer` tại [.agents/skills/hld-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/hld-writer/SKILL.md).
- **Thiết kế Chi tiết Cấp thấp (LLD):** Quy chuẩn [.agents/rules/lld_authoring_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/lld_authoring_rules.md) | Kỹ năng `lld-writer` tại [.agents/skills/lld-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/lld-writer/SKILL.md).
- **Thiết kế CSDL Chi tiết (DBDD):** Quy chuẩn [.agents/rules/db_design_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/db_design_rules.md) | Kỹ năng `db-design-writer` tại [.agents/skills/db-design-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/db-design-writer/SKILL.md).
- **Giải pháp Tổng thể (Master Solution):** Quy chuẩn [.agents/rules/master_solution_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/master_solution_rules.md) | Kỹ năng `master-solution-writer` tại [.agents/skills/master-solution-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/master-solution-writer/SKILL.md).
- **Giải pháp Kỹ thuật (Technical Solution):** Quy chuẩn [.agents/rules/technical_solution_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/technical_solution_rules.md) | Kỹ năng `technical-solution-writer` tại [.agents/skills/technical-solution-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/technical-solution-writer/SKILL.md).
- **Hồ sơ Đề xuất Giải pháp (Proposal):** Quy chuẩn [.agents/rules/proposal_authoring_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/proposal_authoring_rules.md) | Kỹ năng `proposal-writer` tại [.agents/skills/proposal-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/proposal-writer/SKILL.md).
- **Kiến trúc Backend & Xử lý Tiến trình:** Quy chuẩn [.agents/rules/be_process_spec_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/be_process_spec_rules.md) | Kỹ năng `be-process-writer` tại [.agents/skills/be-process-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/be-process-writer/SKILL.md).
- **Kiểm thử Tải cao & Bẫy Dữ liệu Đồng thời:** Quy chuẩn [.agents/rules/loadtest_concurrency_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/loadtest_concurrency_rules.md) | Kỹ năng `loadtest-concurrency-writer` tại [.agents/skills/loadtest-concurrency-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/loadtest-concurrency-writer/SKILL.md).
- **Thiết kế Giao diện UI/UX & Đa ngôn ngữ:** Quy chuẩn [.agents/rules/ui_design_spec_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/ui_design_spec_rules.md) | Kỹ năng `ui-writer` tại [.agents/skills/ui-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/ui-writer/SKILL.md).
- **Nhập/Xuất Dữ liệu Doanh nghiệp:** Quy chuẩn [.agents/rules/enterprise_import_export_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/enterprise_import_export_rules.md) | Kỹ năng `import-export-engine` tại [.agents/skills/import-export-engine/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/import-export-engine/SKILL.md).
- **Hướng dẫn Cài đặt & Vận hành (Runbook):** Quy chuẩn [.agents/rules/operations_guide_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/operations_guide_rules.md) | Kỹ năng `operations-guide-writer` tại [.agents/skills/operations-guide-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/operations-guide-writer/SKILL.md).
- **Hướng dẫn Sử dụng (User Guide):** Quy chuẩn [.agents/rules/user_guide_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/user_guide_rules.md) | Kỹ năng `user-guide-writer` tại [.agents/skills/user-guide-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/user-guide-writer/SKILL.md).
- **Hướng dẫn Upcode & Triển khai (HDUP):** Quy chuẩn [.agents/rules/upcode_guide_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/upcode_guide_rules.md) | Kỹ năng `upcode-guide-writer` tại [.agents/skills/upcode-guide-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/upcode-guide-writer/SKILL.md).
- **Rà soát & Đánh giá Pentest:** Quy chuẩn [.agents/rules/pentest_assessment_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/pentest_assessment_rules.md) & [.agents/rules/security_review_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/security_review_rules.md) | Kỹ năng `pentest-assessment-writer` tại [.agents/skills/pentest-assessment-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/pentest-assessment-writer/SKILL.md).
- **Ước lượng Nỗ lực Viettel:** Quy chuẩn [.agents/rules/viettel_estimation_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/viettel_estimation_rules.md) | Kỹ năng `viettel-estimation-writer` tại [.agents/skills/viettel-estimation-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/viettel-estimation-writer/SKILL.md).
- **Kịch bản & Nghiệm thu UAT:** Quy chuẩn [.agents/rules/viettel_uat_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/viettel_uat_rules.md) | Kỹ năng `viettel-uat-writer` tại [.agents/skills/viettel-uat-writer/SKILL.md](file:///Users/micro/Source/erp/mifinace/.agents/skills/viettel-uat-writer/SKILL.md).
- **Xuất bản Word Docx/PDF:** Quy chuẩn [.agents/rules/docx_export_rules.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/docx_export_rules.md).
- **Chỉ dẫn Soạn thảo Tài liệu:** Quy chuẩn [.agents/rules/documentation_guidelines.md](file:///Users/micro/Source/erp/mifinace/.agents/rules/documentation_guidelines.md).
