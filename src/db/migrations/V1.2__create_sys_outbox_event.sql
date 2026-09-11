-- ====================================================================================
-- DATABASE MIGRATION SCRIPT: V1.2__create_sys_outbox_event.sql
-- HỆ THỐNG: Core Banking Microfinance BMF Myanmar (Cơ sở dữ liệu: NG-mFINA-BMF_20180402)
-- MÔ TẢ: Tạo bảng SYS_OUTBOX_EVENT phục vụ mô hình Outbox Pattern Zero-Impact Core BE
-- ====================================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_OUTBOX_EVENT]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SYS_OUTBOX_EVENT] (
        [Event_ID]           BIGINT IDENTITY(1,1) NOT NULL,              -- Mã sự kiện tự tăng (Khóa chính)
        [Aggregate_Type]     VARCHAR(32)          NOT NULL,              -- Loại nghiệp vụ: 'LOAN', 'SAVING', 'CUSTOMER'
        [Aggregate_ID]       VARCHAR(64)          NOT NULL,              -- Khóa nghiệp vụ (Mã khế ước, Mã sổ tiết kiệm, Mã khách hàng)
        [Event_Type]         VARCHAR(64)          NOT NULL,              -- Loại sự kiện: 'LOAN_DISBURSED', 'PAYMENT_RECEIVED', 'SAVING_DEPOSITED'
        [Payload_JSON]       NVARCHAR(MAX)        NOT NULL,              -- Nội dung chi tiết sự kiện dạng JSON Unicode
        [Status]             VARCHAR(16)          NOT NULL DEFAULT 'PENDING', -- Trạng thái: 'PENDING', 'PROCESSING', 'SENT', 'FAILED'
        [Retry_Count]        INT                  NOT NULL DEFAULT 0,    -- Số lần đã thử gửi lại
        [Max_Retries]        INT                  NOT NULL DEFAULT 5,    -- Số lần tối đa được phép thử lại
        [Error_Message]      NVARCHAR(500)        NULL,                  -- Thông điệp lỗi nếu xử lý thất bại
        [Created_Time]       DATETIME             NOT NULL DEFAULT GETDATE(), -- Thời điểm phát sinh sự kiện từ Trigger
        [Processed_Time]     DATETIME             NULL,                  -- Thời điểm tiến trình Worker bắt đầu xử lý
        [Sent_Time]          DATETIME             NULL,                  -- Thời điểm hoàn tất gửi thông báo
        CONSTRAINT [PK_SYS_OUTBOX_EVENT] PRIMARY KEY CLUSTERED ([Event_ID])
    );

    -- Tạo chỉ mục quét lô trạng thái PENDING tối ưu cho tiến trình Virtual Threads Worker
    CREATE NONCLUSTERED INDEX [IDX_SYS_OUTBOX_PENDING]
    ON [dbo].[SYS_OUTBOX_EVENT] ([Status], [Created_Time])
    INCLUDE ([Event_ID], [Aggregate_Type], [Aggregate_ID], [Event_Type], [Retry_Count])
    WHERE [Status] = 'PENDING';

    -- Tạo chỉ mục tra cứu lịch sử sự kiện theo đối tượng nghiệp vụ
    CREATE NONCLUSTERED INDEX [IDX_SYS_OUTBOX_AGGREGATE]
    ON [dbo].[SYS_OUTBOX_EVENT] ([Aggregate_Type], [Aggregate_ID], [Created_Time]);
END
GO
