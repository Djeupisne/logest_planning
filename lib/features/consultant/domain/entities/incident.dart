// lib/features/consultant/domain/entities/incident.dart
class Incident {
  final int id;
  final int missionId;
  final String type;
  final String description;
  final String? imagePath;
  final DateTime createdAt;
  Incident({required this.id, required this.missionId, required this.type, required this.description, this.imagePath, required this.createdAt});
}
