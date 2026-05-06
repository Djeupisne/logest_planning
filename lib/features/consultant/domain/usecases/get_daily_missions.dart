import 'package:dartz/dartz.dart';
import '../entities/mission.dart';
import '../repositories/mission_repository.dart';
import '../../../../core/error/failures.dart';

class GetDailyMissions {
  final MissionRepository repository;
  GetDailyMissions(this.repository);

  Future<Either<Failure, List<Mission>>> call() => repository.getDailyMissions();
}
