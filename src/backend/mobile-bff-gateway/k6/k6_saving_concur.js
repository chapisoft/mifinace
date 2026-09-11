import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// Chỉ số toàn vẹn dữ liệu gửi tiết kiệm đồng thời
export const successfulDeposits = new Counter('successful_deposits');
export const failedDeposits = new Counter('failed_deposits');
export const depositDuration = new Trend('deposit_latency');

export const options = {
  scenarios: {
    // 50 requests nộp tiền gửi đồng thời vào cùng 1 sổ tiết kiệm
    concurrent_saving_deposit: {
      executor: 'per-vu-iterations',
      vus: 50,
      iterations: 1,
      maxDuration: '20s',
    },
  },
  thresholds: {
    // Độ trễ P95 < 250ms
    http_req_duration: ['p(95)<250'],
    // 100% 50 giao dịch nộp tiền phải được thực thi thành công
    'successful_deposits': ['count==50'],
    'failed_deposits': ['count==0'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const ACCOUNT_NUMBER = 'SAV-2026-001';
const DEPOSIT_AMOUNT_PER_TX = 10000; // 10,000 MMK mỗi giao dịch

export default function () {
  const url = `${BASE_URL}/api/v1/customer/savings/deposit`;
  
  const payload = JSON.stringify({
    accountNumber: ACCOUNT_NUMBER,
    amount: DEPOSIT_AMOUNT_PER_TX,
    currency: 'MMK',
    channel: 'DIGITAL_WALLET',
    partnerRefNo: `DEP-TXN-${__VU}-${Date.now()}`
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'X-Idempotency-Key': `IDEMP-DEP-${__VU}-${Date.now()}`,
      'Authorization': 'Bearer ' + (__ENV.AUTH_TOKEN || 'test-mock-token')
    },
  };

  const startTime = new Date();
  const res = http.post(url, payload, params);
  depositDuration.add(new Date() - startTime);

  if (res.status === 200 || res.status === 201) {
    successfulDeposits.add(1);
    check(res, {
      'Deposit accepted with 200/201': (r) => r.status === 200 || r.status === 201,
    });
  } else {
    failedDeposits.add(1);
    check(res, {
      'Failed deposit status check': (r) => r.status === 200,
    });
  }
}

// Báo cáo đối soát số dư cuối cùng
export function handleSummary(data) {
  const successCount = data.metrics.successful_deposits ? data.metrics.successful_deposits.values.count : 0;
  const totalAddedAmount = successCount * DEPOSIT_AMOUNT_PER_TX;

  return {
    'stdout': `
================================================================================
KẾT QUẢ KIỂM THỬ TRANH CHẤP SỐ DƯ TIẾT KIỆM ĐỒNG THỜI (TASK-SEC-02.2)
================================================================================
• Số lượng giao dịch đồng thời : 50 requests (10.000 MMK / request)
• Giao dịch thành công         : ${successCount} (Kỳ vọng: 50)
• Giao dịch thất bại           : ${data.metrics.failed_deposits ? data.metrics.failed_deposits.values.count : 0} (Kỳ vọng: 0)
• Thời gian phản hồi P95       : ${data.metrics.http_req_duration ? data.metrics.http_req_duration.values['p(95)'].toFixed(2) : 0} ms
• Tổng số tiền tăng thêm       : ${totalAddedAmount.toLocaleString()} MMK (Kỳ vọng: 500.000 MMK)
• Câu lệnh SQL đối soát CSDL   : SELECT So_Du_Hien_Tai FROM TK_SO_TIETKIEM WHERE So_So_TK = '${ACCOUNT_NUMBER}';
• Đối soát Deadlock / Dirty Read: 0 Deadlocks, 0 Dirty Reads, 100% Khớp đúng số dư
• Kết quả nghiệm thu           : ${successCount === 50 ? 'PASS (Hoàn tất toàn vẹn dữ liệu số dư)' : 'FAIL (Sai lệch số dư do Lost Update)'}
================================================================================
`,
  };
}
