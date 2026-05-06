import 'package:dartz/dartz.dart';
import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/database/hive_models.dart';

class MissionRepositoryImpl implements MissionRepository {
  @override
  Future<Either<Failure, List<Mission>>> getDailyMissions() async {
    try {
      final box = HiveService.missions;
      final missions = box.values.cast<MissionModel>().map((m) => Mission(
        id: m.id,
        consultantId: m.consultantId,
        title: m.title,
        clientName: m.clientName,
        address: m.address,
        latitude: m.latitude,
        longitude: m.longitude,
        scheduledStart: m.scheduledStart,
        scheduledEnd: m.scheduledEnd,
        status: m.status,
        contactName: m.contactName,
        contactPhone: m.contactPhone,
        requiresSignature: m.requiresSignature,
      )).toList();
      return Right(missions);
    } catch (e) {
      return const Left(ServerFailure("Erreur lors du chargement des missions"));
    }
  }

  @override
  Future<Either<Failure, void>> updateMissionStatus(int missionId, String status) async {
    try {
      final box = HiveService.missions;
      for (int i = 0; i < box.length; i++) {
        final m = box.getAt(i) as MissionModel?;
        if (m != null && m.id == missionId) {
          m.status = status;
          await m.save();
          break;
        }
      }
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure("Erreur lors de la mise à jour"));
    }
  }
}
