import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/sync_status.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/saving_deposit.dart';
import '../../domain/repositories/saving_repository.dart';
import 'saving_event.dart';
import 'saving_state.dart';

/// Bloc coordinating village savings search, deposit collections, and passbook opening.
class SavingBloc extends Bloc<SavingEvent, SavingState> {
  final SavingRepository _savingRepository;
  final Uuid _uuid;

  SavingBloc({
    required SavingRepository savingRepository,
    Uuid? uuid,
  })  : _savingRepository = savingRepository,
        _uuid = uuid ?? const Uuid(),
        super(const SavingInitial()) {
    on<LoadSavingAccountsRequested>(_onLoadSavingAccounts);
    on<DepositSavingRequested>(_onDepositSaving);
    on<OpenSavingAccountRequested>(_onOpenSavingAccount);
  }

  Future<void> _onLoadSavingAccounts(LoadSavingAccountsRequested event, Emitter<SavingState> emit) async {
    emit(const SavingLoading());
    try {
      AppLogger.info('Loading savings accounts for center: ${event.centerCode}, query: ${event.query}', tag: 'SavingBloc');
      final accounts = await _savingRepository.getSavingAccounts(
        centerCode: event.centerCode,
        query: event.query,
      );
      emit(SavingLoaded(
        accounts: accounts,
        activeCenterCode: event.centerCode,
        query: event.query,
      ));
    } catch (e, stack) {
      AppLogger.error('Failed to load savings accounts: $e', tag: 'SavingBloc', stackTrace: stack);
      emit(SavingError(e.toString()));
    }
  }

  Future<void> _onDepositSaving(DepositSavingRequested event, Emitter<SavingState> emit) async {
    try {
      AppLogger.info(
        'Submitting field savings deposit: ${event.amountMmk} MMK for ${event.accountNumber}',
        tag: 'SavingBloc',
      );

      final depositId = 'DEP-${DateTime.now().year}-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final idempotencyKey = _uuid.v4();

      final deposit = SavingDeposit(
        depositId: depositId,
        accountNumber: event.accountNumber,
        customerName: event.customerName,
        amountMmk: event.amountMmk,
        newBalanceMmk: 0.0, // Computed in repository
        depositDate: DateTime.now(),
        officerId: event.officerId,
        idempotencyKey: idempotencyKey,
        syncStatus: SyncStatus.pending,
      );

      final processed = await _savingRepository.depositSaving(deposit);
      AppLogger.info('Savings deposit recorded: ${processed.depositId}, new balance: ${processed.newBalanceMmk}', tag: 'SavingBloc');
      emit(SavingDepositSuccessState(processed));

      // Reload accounts list
      final accounts = await _savingRepository.getSavingAccounts();
      emit(SavingLoaded(accounts: accounts));
    } catch (e, stack) {
      AppLogger.error('Failed to process savings deposit: $e', tag: 'SavingBloc', stackTrace: stack);
      emit(SavingError(e.toString()));
    }
  }

  Future<void> _onOpenSavingAccount(OpenSavingAccountRequested event, Emitter<SavingState> emit) async {
    emit(const SavingLoading());
    try {
      AppLogger.info(
        'Opening new savings account: ${event.account.customerName} (${event.account.productType.name})',
        tag: 'SavingBloc',
      );
      final opened = await _savingRepository.openSavingAccount(
        event.account,
        initialDepositMmk: event.initialDepositMmk,
      );
      emit(SavingOpenSuccessState(opened));

      // Reload accounts list
      final accounts = await _savingRepository.getSavingAccounts();
      emit(SavingLoaded(accounts: accounts));
    } catch (e, stack) {
      AppLogger.error('Failed to open savings account: $e', tag: 'SavingBloc', stackTrace: stack);
      emit(SavingError(e.toString()));
    }
  }
}
