import 'package:dartz/dartz.dart';
import '../entities/mission.dart';
import '../../../../core/error/failures.dart';

abstract class MissionRepository {
  Future<Either<Failure, List<Mission>>> getDailyMissions();
  Future<Either<Failure, void>> updateMissionStatus(int missionId, String status);
}
