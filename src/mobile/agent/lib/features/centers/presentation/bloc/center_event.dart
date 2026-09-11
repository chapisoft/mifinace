import 'package:equatable/equatable.dart';

abstract class CenterEvent extends Equatable {
  const CenterEvent();

  @override
  List<Object?> get props => [];
}

class LoadCentersRequested extends CenterEvent {
  final bool forceRefresh;

  const LoadCentersRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SelectCenterRequested extends CenterEvent {
  final String centerCode;

  const SelectCenterRequested(this.centerCode);

  @override
  List<Object?> get props => [centerCode];
}
