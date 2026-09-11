import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/customer_loan_repository.dart';
import 'loan_event.dart';
import 'loan_state.dart';

/// Bloc managing borrower active loan contracts and full repayment schedule installments.
class CustomerLoanBloc extends Bloc<CustomerLoanEvent, CustomerLoanState> {
  final CustomerLoanRepository _loanRepository;

  CustomerLoanBloc({
    required CustomerLoanRepository loanRepository,
  })  : _loanRepository = loanRepository,
        super(const LoanInitial()) {
    on<LoadActiveLoansRequested>(_onLoadActiveLoans);
    on<LoadLoanScheduleRequested>(_onLoadLoanSchedule);
  }

  Future<void> _onLoadActiveLoans(LoadActiveLoansRequested event, Emitter<CustomerLoanState> emit) async {
    emit(const LoanLoading());
    try {
      AppLogger.info('Loading active loan contracts for member: ${event.memberNrc}', tag: 'LoanBloc');
      final loans = await _loanRepository.getActiveLoans(event.memberNrc);
      emit(LoanListLoaded(loans));
    } catch (e, stack) {
      AppLogger.error('Failed to load active loans: $e', tag: 'LoanBloc', stackTrace: stack);
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onLoadLoanSchedule(LoadLoanScheduleRequested event, Emitter<CustomerLoanState> emit) async {
    emit(const LoanLoading());
    try {
      AppLogger.info('Loading full repayment schedule for contract: ${event.contractCode}', tag: 'LoanBloc');
      final schedules = await _loanRepository.getLoanSchedule(event.contractCode);
      emit(LoanScheduleLoaded(contractCode: event.contractCode, schedules: schedules));
    } catch (e, stack) {
      AppLogger.error('Failed to load loan schedule: $e', tag: 'LoanBloc', stackTrace: stack);
      emit(LoanError(e.toString()));
    }
  }
}
