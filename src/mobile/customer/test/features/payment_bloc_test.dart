import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_customer/features/payments/domain/models/mmqr_payment.dart';
import 'package:bmf_customer/features/payments/domain/repositories/payment_repository.dart';
import 'package:bmf_customer/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:bmf_customer/features/payments/presentation/bloc/payment_event.dart';
import 'package:bmf_customer/features/payments/presentation/bloc/payment_state.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository mockPaymentRepository;
  late PaymentBloc paymentBloc;

  final testPayment = MmqrPayment(
    transactionReference: 'BMF-TX-1712000000-ABCDEF',
    contractCode: 'AGRI-KYA-001',
    amountMmk: 48000.0,
    mmqrPayload: '00020101021226360012mm.gov.cbm.mmqr53031045405480005802MM5916BMF MICROFINANCE6304ABCD',
    generatedAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    billerName: 'BMF Microfinance Myanmar',
  );

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    paymentBloc = PaymentBloc(paymentRepository: mockPaymentRepository);
  });

  tearDown(() {
    paymentBloc.close();
  });

  group('PaymentBloc Tests', () {
    test('Initial state should be PaymentInitial', () {
      expect(paymentBloc.state, isA<PaymentInitial>());
    });

    test('GenerateMmqrRequested emits MmqrGenerated on success', () async {
      when(() => mockPaymentRepository.generateLoanPaymentQr(
            contractCode: 'AGRI-KYA-001',
            amountMmk: 48000.0,
          )).thenAnswer((_) async => testPayment);

      paymentBloc.add(const GenerateMmqrRequested(
        contractCode: 'AGRI-KYA-001',
        amountMmk: 48000.0,
      ));

      await expectLater(
        paymentBloc.stream,
        emitsInOrder([
          const PaymentLoading(),
          isA<MmqrGenerated>().having(
            (s) => s.payment.transactionReference,
            'transactionReference',
            'BMF-TX-1712000000-ABCDEF',
          ).having(
            (s) => s.payment.amountMmk,
            'amountMmk',
            48000.0,
          ).having(
            (s) => s.payment.isExpired,
            'isExpired',
            isFalse,
          ),
        ]),
      );
    });

    test('GenerateMmqrRequested emits PaymentFailure when repository throws', () async {
      when(() => mockPaymentRepository.generateLoanPaymentQr(
            contractCode: 'AGRI-KYA-001',
            amountMmk: 48000.0,
          )).thenThrow(Exception('MMQR Generation Gateway Timeout'));

      paymentBloc.add(const GenerateMmqrRequested(
        contractCode: 'AGRI-KYA-001',
        amountMmk: 48000.0,
      ));

      await expectLater(
        paymentBloc.stream,
        emitsInOrder([
          const PaymentLoading(),
          isA<PaymentFailure>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('MMQR Generation Gateway Timeout'),
          ),
        ]),
      );
    });

    test('PollPaymentStatusRequested emits PaymentSuccess when Core marks settled', () async {
      when(() => mockPaymentRepository.checkPaymentStatus('BMF-TX-1712000000-ABCDEF'))
          .thenAnswer((_) async => true);

      paymentBloc.add(const PollPaymentStatusRequested(
        transactionReference: 'BMF-TX-1712000000-ABCDEF',
        contractCode: 'AGRI-KYA-001',
        amountMmk: 48000.0,
      ));

      await expectLater(
        paymentBloc.stream,
        emitsInOrder([
          isA<PaymentSuccess>().having(
            (s) => s.transactionReference,
            'transactionReference',
            'BMF-TX-1712000000-ABCDEF',
          ).having(
            (s) => s.amountMmk,
            'amountMmk',
            48000.0,
          ),
        ]),
      );
    });

    test('LaunchWalletRequested triggers repository launchWalletApp', () async {
      when(() => mockPaymentRepository.launchWalletApp(
            walletScheme: any(named: 'walletScheme'),
            mmqrPayload: any(named: 'mmqrPayload'),
          )).thenAnswer((_) async => true);

      paymentBloc.add(const LaunchWalletRequested(
        walletScheme: 'kbzpay://qrpay',
        mmqrPayload: 'sample_payload',
      ));

      await Future.delayed(const Duration(milliseconds: 50));
      verify(() => mockPaymentRepository.launchWalletApp(
            walletScheme: 'kbzpay://qrpay',
            mmqrPayload: 'sample_payload',
          )).called(1);
    });

    test('ResetPaymentRequested emits PaymentInitial', () async {
      paymentBloc.add(const ResetPaymentRequested());

      await expectLater(
        paymentBloc.stream,
        emitsInOrder([
          const PaymentInitial(),
        ]),
      );
    });
  });
}
