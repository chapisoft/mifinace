import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/services/cash_management_service.dart';
import 'cash_event.dart';
import 'cash_state.dart';

/// Bloc managing mobile cash balance, threshold warnings, and cashier handover QR codes.
class CashBloc extends Bloc<CashEvent, CashState> {
  final CashManagementService _cashService;

  CashBloc({
    required CashManagementService cashService,
  })  : _cashService = cashService,
        super(const CashInitial()) {
    on<LoadCashSummaryRequested>(_onLoadSummary);
    on<GenerateHandoverQrRequested>(_onGenerateHandoverQr);
    on<ConfirmHandoverCompletedRequested>(_onConfirmHandover);
  }

  Future<void> _onLoadSummary(LoadCashSummaryRequested event, Emitter<CashState> emit) async {
    emit(const CashLoading());
    try {
      AppLogger.info('Loading physical cash summary for officer: ${event.officerId}', tag: 'CashBloc');
      final summary = await _cashService.getCashSummary(event.officerId);
      emit(CashLoaded(summary));
    } catch (e, stack) {
      AppLogger.error('Failed to calculate cash summary: $e', tag: 'CashBloc', stackTrace: stack);
      emit(CashError(e.toString()));
    }
  }

  Future<void> _onGenerateHandoverQr(GenerateHandoverQrRequested event, Emitter<CashState> emit) async {
    try {
      AppLogger.info('Generating cashier handover QR code for officer: ${event.officerId}', tag: 'CashBloc');
      final summary = await _cashService.getCashSummary(event.officerId);
      final qrPayload = await _cashService.generateHandoverQrPayload(event.officerId);
      emit(CashHandoverQrGeneratedState(summary: summary, qrPayload: qrPayload));
    } catch (e, stack) {
      AppLogger.error('Failed to generate handover QR: $e', tag: 'CashBloc', stackTrace: stack);
      emit(CashError(e.toString()));
    }
  }

  Future<void> _onConfirmHandover(ConfirmHandoverCompletedRequested event, Emitter<CashState> emit) async {
    emit(const CashLoading());
    try {
      AppLogger.info('Confirming cashier cash handover ref: ${event.referenceId}', tag: 'CashBloc');
      await _cashService.completeHandover(event.officerId, event.referenceId);
      emit(CashHandoverSuccessState(event.referenceId));

      final updatedSummary = await _cashService.getCashSummary(event.officerId);
      emit(CashLoaded(updatedSummary));
    } catch (e, stack) {
      AppLogger.error('Failed to confirm cash handover: $e', tag: 'CashBloc', stackTrace: stack);
      emit(CashError(e.toString()));
    }
  }
}
