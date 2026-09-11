import 'package:equatable/equatable.dart';
import '../../domain/models/insurance_claim.dart';

abstract class InsuranceClaimState extends Equatable {
  const InsuranceClaimState();

  @override
  List<Object?> get props => [];
}

class InsuranceClaimInitial extends InsuranceClaimState {
  const InsuranceClaimInitial();
}

class InsuranceClaimLoading extends InsuranceClaimState {
  const InsuranceClaimLoading();
}

class InsuranceClaimLoaded extends InsuranceClaimState {
  final List<InsuranceClaim> claims;

  const InsuranceClaimLoaded(this.claims);

  @override
  List<Object?> get props => [claims];
}

class InsuranceClaimSubmittedState extends InsuranceClaimState {
  final InsuranceClaim claim;

  const InsuranceClaimSubmittedState(this.claim);

  @override
  List<Object?> get props => [claim];
}

class InsuranceClaimError extends InsuranceClaimState {
  final String errorMessage;

  const InsuranceClaimError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
