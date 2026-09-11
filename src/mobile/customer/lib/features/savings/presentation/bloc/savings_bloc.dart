import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';
import '../../domain/repositories/savings_repository.dart';
import 'savings_event.dart';
import 'savings_state.dart';

/// Bloc managing borrower savings accounts and online term deposit subscriptions.
class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final SavingsRepository _savingsRepository;

  SavingsBloc({required SavingsRepository savingsRepository})
      : _savingsRepository = savingsRepository,
        super(const SavingsInitial()) {
    on<LoadSavingsAccountsRequested>(_onLoadSavingsAccounts);
    on<OpenSavingAccountRequested>(_onOpenSavingAccount);
  }

  Future<void> _onLoadSavingsAccounts(LoadSavingsAccountsRequested event, Emitter<SavingsState> emit) async {
    emit(const SavingsLoading());
    try {
      AppLogger.info('Loading savings passbooks for member: ${event.memberNrc}', tag: 'SavingsBloc');
      final accounts = await _savingsRepository.getSavingAccounts(event.memberNrc);
      emit(SavingsLoaded(accounts));
    } catch (e, stack) {
      AppLogger.error('Failed to load savings accounts: $e', tag: 'SavingsBloc', stackTrace: stack);
      emit(SavingsFailure(e.toString()));
    }
  }

  Future<void> _onOpenSavingAccount(OpenSavingAccountRequested event, Emitter<SavingsState> emit) async {
    emit(const SavingsLoading());
    try {
      AppLogger.info('Subscribing to new savings plan for member: ${event.memberNrc}', tag: 'SavingsBloc');
      final newAccount = await _savingsRepository.openFixedTermSaving(
        memberNrc: event.memberNrc,
        initialDepositMmk: event.initialDepositMmk,
        tenureMonths: event.tenureMonths,
        beneficiaryName: event.beneficiaryName,
      );
      emit(SavingAccountOpenedSuccess(newAccount));
    } catch (e, stack) {
      AppLogger.error('Failed to open savings account: $e', tag: 'SavingsBloc', stackTrace: stack);
      emit(SavingsFailure(e.toString()));
    }
  }
}
