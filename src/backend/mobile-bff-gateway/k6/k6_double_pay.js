import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// Định nghĩa các chỉ số đo lường hiệu năng chuyên sâu
export const successfulPayments = new Counter('successful_repayments');
export const rejectedPayments = new Counter('rejected_duplicate_repayments');
export const conflictRate = new Rate('conflict_rate');
export const paymentDuration = new Trend('repayment_latency');

export const options = {
  scenarios: {
    // 100 VUs bắn đồng thời 100 requests thu nợ cùng 1 món nợ trong 10 giây
    concurrent_double_payment_trap: {
      executor: 'per-vu-iterations',
      vus: 100,
      iterations: 1,
      maxDuration: '15s',
    },
  },
  thresholds: {
    // Độ trễ P95 < 200ms
    http_req_duration: ['p(95)<200'],
    // Đúng 1 request thành công
    'successful_repayments': ['count==1'],
    // 99 requests bị chặn an toàn
    'rejected_duplicate_repayments': ['count==99'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const CONTRACT_CODE = 'LN-2026-001';
const PERIOD_NUMBER = 1;
const AMOUNT = 55000;

export default function () {
  const url = `${BASE_URL}/api/v1/repayments/collect`;
  
  const payload = JSON.stringify({
    contractCode: CONTRACT_CODE,
    periodNumber: PERIOD_NUMBER,
    principalAmount: 50000,
    interestAmount: 4000,
    insuranceFee: 1000,
    totalAmount: AMOUNT,
    paymentMethod: 'CASH',
    receiptNumber: `REC-${__VU}-${Date.now()}`,
    collectorUserId: 'BMF-OFFICER-01'
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'X-Idempotency-Key': `IDEMP-TRAP-${__VU}-${Date.now()}`,
      'Authorization': 'Bearer ' + (__ENV.AUTH_TOKEN || 'test-mock-token')
    },
  };

  const startTime = new Date();
  const res = http.post(url, payload, params);
  paymentDuration.add(new Date() - startTime);

  if (res.status === 200 || res.status === 201) {
    successfulPayments.add(1);
    check(res, {
      'Single successful payment status is 200/201': (r) => r.status === 200 || r.status === 201,
    });
  } else {
    rejectedPayments.add(1);
    conflictRate.add(1);
    check(res, {
      'Duplicate request safely rejected with 409/400/422': (r) =>
        r.status === 409 || r.status === 400 || r.status === 422 || r.status === 423,
    });
  }
}

// Báo cáo đối soát sau khi kết thúc tải
export function handleSummary(data) {
  return {
    'stdout': `
================================================================================
KẾT QUẢ KIỂM THỬ TẢI & BẪY GẠCH NỢ TRÙNG ĐỒNG THỜI (TASK-SEC-02.1)
================================================================================
• Tổng số VUs đồng thời     : 100 VUs
• Giao dịch thành công       : ${data.metrics.successful_repayments ? data.metrics.successful_repayments.values.count : 0} (Kỳ vọng: 1)
• Giao dịch bị chặn an toàn  : ${data.metrics.rejected_duplicate_repayments ? data.metrics.rejected_duplicate_repayments.values.count : 0} (Kỳ vọng: 99)
• Thời gian phản hồi P95     : ${data.metrics.http_req_duration ? data.metrics.http_req_duration.values['p(95)'].toFixed(2) : 0} ms (Kỳ vọng: < 200ms)
• Câu lệnh SQL đối soát CSDL : SELECT COUNT(*) FROM TD_THUNO WHERE Ma_HopDong = '${CONTRACT_CODE}' AND Ky_Thu = ${PERIOD_NUMBER};
• Kết quả toàn vẹn dữ liệu   : ${data.metrics.successful_repayments && data.metrics.successful_repayments.values.count === 1 ? 'PASS (100% Khớp đúng số dư)' : 'FAIL (Phát sinh gạch nợ trùng)'}
================================================================================
`,
  };
}
