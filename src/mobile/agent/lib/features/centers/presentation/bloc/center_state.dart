import 'package:equatable/equatable.dart';
import '../../domain/entities/center_item.dart';
import '../../domain/entities/group_item.dart';

abstract class CenterState extends Equatable {
  const CenterState();

  @override
  List<Object?> get props => [];
}

class CenterInitial extends CenterState {
  const CenterInitial();
}

class CenterLoading extends CenterState {
  const CenterLoading();
}

class CenterLoaded extends CenterState {
  final List<CenterItem> centers;
  final List<GroupItem> groups;
  final CenterItem? selectedCenter;

  const CenterLoaded({
    required this.centers,
    this.groups = const [],
    this.selectedCenter,
  });

  CenterLoaded copyWith({
    List<CenterItem>? centers,
    List<GroupItem>? groups,
    CenterItem? selectedCenter,
  }) {
    return CenterLoaded(
      centers: centers ?? this.centers,
      groups: groups ?? this.groups,
      selectedCenter: selectedCenter ?? this.selectedCenter,
    );
  }

  @override
  List<Object?> get props => [centers, groups, selectedCenter];
}

class CenterError extends CenterState {
  final String message;

  const CenterError(this.message);

  @override
  List<Object?> get props => [message];
}
