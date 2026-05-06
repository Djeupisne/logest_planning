import 'package:dartz/dartz.dart';
import '../repositories/mission_repository.dart';
import '../../../../core/error/failures.dart';

class UpdateMissionStatus {
  final MissionRepository repository;
  UpdateMissionStatus(this.repository);

  Future<Either<Failure, void>> call(int missionId, String status) =>
      repository.updateMissionStatus(missionId, status);
}
