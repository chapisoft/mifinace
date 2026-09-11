import 'package:equatable/equatable.dart';
import '../../domain/models/sync_summary.dart';

abstract class SyncState extends Equatable {
  final SyncSummary? summary;

  const SyncState({this.summary});

  @override
  List<Object?> get props => [summary];
}

class SyncInitial extends SyncState {
  const SyncInitial() : super();
}

class SyncLoading extends SyncState {
  const SyncLoading({super.summary});
}

class SyncInProgressState extends SyncState {
  final String statusMessage;

  const SyncInProgressState({
    required this.statusMessage,
    super.summary,
  });

  @override
  List<Object?> get props => [statusMessage, summary];
}

class SyncSuccessState extends SyncState {
  final String message;

  const SyncSuccessState({
    required this.message,
    required SyncSummary summary,
  }) : super(summary: summary);

  @override
  List<Object?> get props => [message, summary];
}

class SyncFailureState extends SyncState {
  final String errorMessage;

  const SyncFailureState({
    required this.errorMessage,
    super.summary,
  });

  @override
  List<Object?> get props => [errorMessage, summary];
}
