import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/app_language.dart';
import 'package:bmf_agent_app/core/enums/debt_group.dart';
import 'package:bmf_agent_app/core/enums/repayment_method.dart';
import 'package:bmf_agent_app/core/enums/repayment_status.dart';
import 'package:bmf_agent_app/core/enums/sync_operation.dart';
import 'package:bmf_agent_app/core/enums/sync_status.dart';
import 'package:bmf_agent_app/core/enums/user_role.dart';

void main() {
  group('100% Enum-Driven & Zero-Hardcode Tests for BMF Agent App', () {
    test('UserRole enum parses from code correctly', () {
      expect(UserRole.fromCode('CREDIT_OFFICER'), UserRole.creditOfficer);
      expect(UserRole.fromCode('BRANCH_MANAGER'), UserRole.branchManager);
      expect(UserRole.fromCode('CUSTOMER_MEMBER'), UserRole.customerMember);
      expect(UserRole.fromCode(null), UserRole.creditOfficer);
    });

    test('RepaymentStatus enum parses from code correctly', () {
      expect(RepaymentStatus.fromCode('PENDING'), RepaymentStatus.pending);
      expect(RepaymentStatus.fromCode('PAID_LOCAL'), RepaymentStatus.paidLocal);
      expect(RepaymentStatus.fromCode('SYNCED'), RepaymentStatus.synced);
      expect(RepaymentStatus.fromCode('SETTLED'), RepaymentStatus.settled);
    });

    test('RepaymentMethod enum parses from code correctly', () {
      expect(RepaymentMethod.fromCode('CASH'), RepaymentMethod.cash);
      expect(RepaymentMethod.fromCode('MMQR'), RepaymentMethod.mmqr);
      expect(RepaymentMethod.fromCode('KBZ_PAY'), RepaymentMethod.kbzPay);
      expect(RepaymentMethod.fromCode('WAVE_PAY'), RepaymentMethod.wavePay);
      expect(RepaymentMethod.fromCode('AYA_PAY'), RepaymentMethod.ayaPay);
      expect(RepaymentMethod.fromCode('MYTEL_PAY'), RepaymentMethod.mytelPay);
    });

    test('DebtGroup classifies overdue days into 5 FRD groups', () {
      expect(DebtGroup.fromDays(15), DebtGroup.standard);
      expect(DebtGroup.fromDays(45), DebtGroup.watch);
      expect(DebtGroup.fromDays(75), DebtGroup.substandard);
      expect(DebtGroup.fromDays(120), DebtGroup.doubtful);
      expect(DebtGroup.fromDays(200), DebtGroup.loss);
    });

    test('AppLanguage supports all 6 languages', () {
      expect(AppLanguage.values.length, 6);
      expect(AppLanguage.fromCode('my'), AppLanguage.myanmar);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('vi'), AppLanguage.vietnamese);
      expect(AppLanguage.fromCode('zh'), AppLanguage.chinese);
      expect(AppLanguage.fromCode('ja'), AppLanguage.japanese);
      expect(AppLanguage.fromCode('ko'), AppLanguage.korean);
    });

    test('SyncStatus and SyncOperation enums validate properly', () {
      expect(SyncStatus.fromCode('PENDING'), SyncStatus.pending);
      expect(SyncStatus.fromCode('SYNCING'), SyncStatus.syncing);
      expect(SyncOperation.fromCode('COLLECT_REPAYMENT'), SyncOperation.collectRepayment);
      expect(SyncOperation.fromCode('LOAN_APPLICATION'), SyncOperation.loanApplication);
    });
  });
}
