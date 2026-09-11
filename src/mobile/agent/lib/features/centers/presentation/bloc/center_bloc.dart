import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/center_repository.dart';
import 'center_event.dart';
import 'center_state.dart';

/// Bloc managing Centers & Groups exploration and selection in the field.
class CenterBloc extends Bloc<CenterEvent, CenterState> {
  final CenterRepository _centerRepository;

  CenterBloc({required CenterRepository centerRepository})
      : _centerRepository = centerRepository,
        super(const CenterInitial()) {
    on<LoadCentersRequested>(_onLoadCenters);
    on<SelectCenterRequested>(_onSelectCenter);
  }

  Future<void> _onLoadCenters(LoadCentersRequested event, Emitter<CenterState> emit) async {
    emit(const CenterLoading());
    try {
      final centers = await _centerRepository.getCenters(forceRefresh: event.forceRefresh);
      AppLogger.info('Loaded ${centers.length} centers for field officer', tag: 'CenterBloc');
      emit(CenterLoaded(centers: centers));
    } catch (e, stack) {
      AppLogger.error('Failed to load centers: $e', tag: 'CenterBloc', stackTrace: stack);
      emit(CenterError(e.toString()));
    }
  }

  Future<void> _onSelectCenter(SelectCenterRequested event, Emitter<CenterState> emit) async {
    if (state is CenterLoaded) {
      final currentState = state as CenterLoaded;
      final selectedCenter = currentState.centers.firstWhere(
        (c) => c.centerCode == event.centerCode,
        orElse: () => currentState.centers.first,
      );

      try {
        final groups = await _centerRepository.getGroupsByCenter(event.centerCode);
        AppLogger.info('Loaded ${groups.length} groups for center ${event.centerCode}', tag: 'CenterBloc');
        emit(currentState.copyWith(selectedCenter: selectedCenter, groups: groups));
      } catch (e) {
        AppLogger.warn('Failed to load groups for center ${event.centerCode}: $e', tag: 'CenterBloc');
        emit(currentState.copyWith(selectedCenter: selectedCenter, groups: []));
      }
    }
  }
}
