part of 'mission_bloc.dart';

abstract class MissionState extends Equatable {
  @override
  List<Object> get props => [];
}

class MissionInitial extends MissionState {}
class MissionLoading extends MissionState {}

class MissionError extends MissionState {
  final String message;
  MissionError(this.message);
  @override
  List<Object> get props => [message];
}

class MissionLoaded extends MissionState {
  final List<Mission> missions;
  MissionLoaded(this.missions);
  @override
  List<Object> get props => [missions];
}