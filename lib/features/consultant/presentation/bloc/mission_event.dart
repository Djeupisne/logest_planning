part of 'mission_bloc.dart';

abstract class MissionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMissions extends MissionEvent {}

class UpdateStatus extends MissionEvent {
  final int missionId;
  final String status;
  UpdateStatus(this.missionId, this.status);
  @override
  List<Object> get props => [missionId, status];
}