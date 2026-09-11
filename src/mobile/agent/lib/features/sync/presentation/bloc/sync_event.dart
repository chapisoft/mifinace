import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class LoadSyncSummaryRequested extends SyncEvent {
  const LoadSyncSummaryRequested();
}

class TriggerManualSyncRequested extends SyncEvent {
  const TriggerManualSyncRequested();
}
