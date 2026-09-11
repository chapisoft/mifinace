import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Bloc managing loan installment payment lifecycle: MMQR generation, wallet launches, and settlement confirmation.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(const PaymentInitial()) {
    on<GenerateMmqrRequested>(_onGenerateMmqr);
    on<PollPaymentStatusRequested>(_onPollPaymentStatus);
    on<LaunchWalletRequested>(_onLaunchWallet);
    on<ResetPaymentRequested>(_onResetPayment);
  }

  Future<void> _onGenerateMmqr(GenerateMmqrRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    try {
      AppLogger.info('Generating MMQR payment for: ${event.contractCode}', tag: 'PaymentBloc');
      final payment = await _paymentRepository.generateLoanPaymentQr(
        contractCode: event.contractCode,
        amountMmk: event.amountMmk,
      );
      emit(MmqrGenerated(payment));
    } catch (e, stack) {
      AppLogger.error('Failed to generate MMQR: $e', tag: 'PaymentBloc', stackTrace: stack);
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onPollPaymentStatus(PollPaymentStatusRequested event, Emitter<PaymentState> emit) async {
    try {
      final isSettled = await _paymentRepository.checkPaymentStatus(event.transactionReference);
      if (isSettled) {
        AppLogger.info('Payment confirmed settled for ref: ${event.transactionReference}', tag: 'PaymentBloc');
        emit(PaymentSuccess(
          transactionReference: event.transactionReference,
          contractCode: event.contractCode,
          amountMmk: event.amountMmk,
          settledAt: DateTime.now(),
        ));
      }
    } catch (e) {
      AppLogger.warn('Error polling payment status: $e', tag: 'PaymentBloc');
    }
  }

  Future<void> _onLaunchWallet(LaunchWalletRequested event, Emitter<PaymentState> emit) async {
    try {
      AppLogger.info('Launching external wallet: ${event.walletScheme}', tag: 'PaymentBloc');
      await _paymentRepository.launchWalletApp(
        walletScheme: event.walletScheme,
        mmqrPayload: event.mmqrPayload,
      );
    } catch (e) {
      AppLogger.error('Failed to launch wallet: $e', tag: 'PaymentBloc');
    }
  }

  void _onResetPayment(ResetPaymentRequested event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
