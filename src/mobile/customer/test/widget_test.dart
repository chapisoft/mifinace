import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_customer/core/enums/debt_group.dart';
import 'package:bmf_customer/core/enums/loan_type.dart';
import 'package:bmf_customer/core/enums/repayment_status.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';
import 'package:bmf_customer/features/auth/presentation/widgets/random_numeric_keypad.dart';
import 'package:bmf_customer/features/home/presentation/widgets/due_loan_alert_card.dart';
import 'package:bmf_customer/features/home/presentation/widgets/member_card.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_loan.dart';
import 'package:bmf_customer/features/loans/domain/models/customer_schedule_item.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/loan_card.dart';
import 'package:bmf_customer/features/loans/presentation/widgets/schedule_item_widget.dart';

void main() {
  group('Customer Mobile App Widget Tests', () {
    testWidgets('RandomNumericKeypad renders buttons and responds to taps', (tester) async {
      String tappedNumber = '';
      bool backspaceTapped = false;
      bool biometricTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RandomNumericKeypad(
              onKeyPressed: (digit) => tappedNumber = digit,
              onDeletePressed: () => backspaceTapped = true,
              showBiometric: true,
              onBiometricPressed: () => biometricTapped = true,
            ),
          ),
        ),
      );

      // Verify backspace button exists
      final backspaceFinder = find.byIcon(Icons.backspace_outlined);
      expect(backspaceFinder, findsOneWidget);
      await tester.tap(backspaceFinder);
      expect(backspaceTapped, isTrue);

      // Verify biometric button exists
      final biometricFinder = find.byIcon(Icons.fingerprint);
      expect(biometricFinder, findsOneWidget);
      await tester.tap(biometricFinder);
      expect(biometricTapped, isTrue);

      // Tap on any digit button (0-9)
      final digitFinder = find.text('1');
      expect(digitFinder, findsOneWidget);
      await tester.tap(digitFinder);
      expect(tappedNumber, '1');
    });

    testWidgets('MemberCard renders member profile correctly', (tester) async {
      bool qrTapped = false;
      const member = MemberProfile(
        memberId: 'MBR-001',
        nrcFormatted: '12/DAGAMA(N)098765',
        fullName: 'Daw Khin Khin',
        phone: '09791234567',
        centerName: 'Kyauktada Center 01',
        groupName: 'Solidarity Group A',
        totalSavingBalanceMmk: 50000.0,
        loyaltyPoints: 100,
        hasActiveLoans: true,
        isPinConfigured: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberCard(
              member: member,
              onQrTap: () => qrTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Daw Khin Khin'), findsOneWidget);
      expect(find.text('NRC: 12/DAGAMA(N)098765'), findsOneWidget);
      expect(find.text('Kyauktada Center 01'), findsOneWidget);
      expect(find.text('Solidarity Group A'), findsOneWidget);

      final qrFinder = find.text('Member ID');
      expect(qrFinder, findsOneWidget);
      await tester.tap(qrFinder);
      expect(qrTapped, isTrue);
    });

    testWidgets('LoanCard renders financial summary and triggers callbacks', (tester) async {
      bool scheduleTapped = false;
      bool payTapped = false;

      final loan = CustomerLoan(
        loanId: 'LN-2026-001',
        contractCode: 'AGRI-KYA-001',
        loanType: LoanType.agricultureSeasonal,
        disbursedAmountMmk: 500000.0,
        totalRepaidMmk: 200000.0,
        remainingPrincipalMmk: 300000.0,
        interestRateAnnual: 28.0,
        disbursedDate: DateTime(2026, 1, 15),
        maturityDate: DateTime(2027, 1, 15),
        totalPeriods: 12,
        paidPeriods: 4,
        debtGroup: DebtGroup.current,
        nextDueDate: DateTime.now().add(const Duration(days: 2)),
        nextDueAmountMmk: 48000.0,
        isDueSoon: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoanCard(
              loan: loan,
              onViewSchedule: () => scheduleTapped = true,
              onPayNow: () => payTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Contract: AGRI-KYA-001'), findsOneWidget);
      expect(find.text(DebtGroup.current.label), findsOneWidget);
      expect(find.text('Seasonal Agriculture Loan'), findsOneWidget);

      // Verify action buttons
      final scheduleBtn = find.text('View Schedule');
      expect(scheduleBtn, findsOneWidget);
      await tester.tap(scheduleBtn);
      expect(scheduleTapped, isTrue);

      final payBtn = find.text('Pay Installment');
      expect(payBtn, findsOneWidget);
      await tester.tap(payBtn);
      expect(payTapped, isTrue);
    });

    testWidgets('ScheduleItemWidget renders installment details and badge', (tester) async {
      final scheduleItem = CustomerScheduleItem(
        scheduleId: 'SCH-001',
        periodNumber: 1,
        dueDate: DateTime(2026, 2, 15),
        principalDueMmk: 40000.0,
        interestDueMmk: 7000.0,
        insuranceFeeMmk: 500.0,
        savingFeeMmk: 1000.0,
        totalDueMmk: 48500.0,
        status: RepaymentStatus.paid,
        paidDate: DateTime(2026, 2, 14),
        overdueDays: 0,
        debtGroup: DebtGroup.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleItemWidget(item: scheduleItem),
          ),
        ),
      );

      expect(find.text('Period #1'), findsOneWidget);
      expect(find.text('Paid (14/2)'), findsOneWidget);
    });

    testWidgets('DueLoanAlertCard renders due alert and triggers callback', (tester) async {
      bool payTapped = false;
      final loan = CustomerLoan(
        loanId: 'LN-2026-001',
        contractCode: 'AGRI-KYA-001',
        loanType: LoanType.agricultureSeasonal,
        disbursedAmountMmk: 500000.0,
        totalRepaidMmk: 200000.0,
        remainingPrincipalMmk: 300000.0,
        interestRateAnnual: 28.0,
        disbursedDate: DateTime(2026, 1, 15),
        maturityDate: DateTime(2027, 1, 15),
        totalPeriods: 12,
        paidPeriods: 4,
        debtGroup: DebtGroup.current,
        nextDueDate: DateTime.now().add(const Duration(days: 2)),
        nextDueAmountMmk: 48000.0,
        isDueSoon: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueLoanAlertCard(
              loan: loan,
              onPayNow: () => payTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Upcoming Installment Due Soon'), findsOneWidget);
      final payBtn = find.text('Pay via MMQR');
      expect(payBtn, findsOneWidget);
      await tester.tap(payBtn);
      expect(payTapped, isTrue);
    });
  });
}
