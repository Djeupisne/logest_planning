import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/mission.dart';
import '../../domain/usecases/get_daily_missions.dart';
import '../../domain/usecases/update_mission_status.dart';

part 'mission_event.dart';
part 'mission_state.dart';

class MissionBloc extends Bloc<MissionEvent, MissionState> {
  final GetDailyMissions getDailyMissions;
  final UpdateMissionStatus updateMissionStatus;

  MissionBloc({required this.getDailyMissions, required this.updateMissionStatus})
      : super(MissionInitial()) {
    on<LoadMissions>((event, emit) async {
      emit(MissionLoading());
      final result = await getDailyMissions();
      result.fold(
        (failure) => emit(MissionError(failure.message)),
        (missions) => emit(MissionLoaded(missions)),
      );
    });

    on<UpdateStatus>((event, emit) async {
      await updateMissionStatus(event.missionId, event.status);
      add(LoadMissions());
    });
  }
}
