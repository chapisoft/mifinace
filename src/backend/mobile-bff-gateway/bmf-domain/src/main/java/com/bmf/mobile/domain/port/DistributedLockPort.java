package com.bmf.mobile.domain.port;

import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * Cổng giao tiếp khóa phân tán Distributed Lock trên Redis (Domain Port).
 */
public interface DistributedLockPort {

    /**
     * Thử lấy khóa phân tán và thực thi logic nghiệp vụ trong khối an toàn.
     *
     * @param lockKey  khóa định danh duy nhất của tài nguyên cần khóa
     * @param waitTime thời gian tối đa chờ để lấy khóa
     * @param leaseTime thời gian tự động giải phóng khóa nếu tiến trình gặp sự cố
     * @param unit đơn vị thời gian
     * @param action logic nghiệp vụ cần thực thi
     * @param <T> kiểu dữ liệu trả về
     * @return kết quả trả về từ logic nghiệp vụ
     */
    <T> T executeWithLock(String lockKey, long waitTime, long leaseTime, TimeUnit unit, Supplier<T> action);

    /**
     * Thử lấy khóa phân tán không trả về kết quả (Runnable).
     */
    void executeWithLock(String lockKey, long waitTime, long leaseTime, TimeUnit unit, Runnable action);
}
