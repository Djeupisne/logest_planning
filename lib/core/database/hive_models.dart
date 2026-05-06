import 'package:hive/hive.dart';

// ─── UserModel ───────────────────────────────────────────
class UserModel extends HiveObject {
  int id;
  String email;
  String fullName;
  String role;
  String password;
  String? phone;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.password,
    this.phone,
  });
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.readInt(),
      email: reader.readString(),
      fullName: reader.readString(),
      role: reader.readString(),
      password: reader.readString(),
      phone: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.email);
    writer.writeString(obj.fullName);
    writer.writeString(obj.role);
    writer.writeString(obj.password);
    writer.write(obj.phone);
  }
}

// ─── MissionModel ─────────────────────────────────────────
class MissionModel extends HiveObject {
  int id;
  int consultantId;
  String title;
  String clientName;
  String address;
  double? latitude;
  double? longitude;
  DateTime scheduledStart;
  DateTime scheduledEnd;
  String status;
  String? contactName;
  String? contactPhone;
  bool requiresSignature;

  MissionModel({
    required this.id,
    required this.consultantId,
    required this.title,
    required this.clientName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    this.contactName,
    this.contactPhone,
    this.requiresSignature = false,
  });
}

class MissionModelAdapter extends TypeAdapter<MissionModel> {
  @override
  final int typeId = 1;

  @override
  MissionModel read(BinaryReader reader) {
    return MissionModel(
      id: reader.readInt(),
      consultantId: reader.readInt(),
      title: reader.readString(),
      clientName: reader.readString(),
      address: reader.readString(),
      latitude: reader.read() as double?,
      longitude: reader.read() as double?,
      scheduledStart: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      scheduledEnd: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      status: reader.readString(),
      contactName: reader.read() as String?,
      contactPhone: reader.read() as String?,
      requiresSignature: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, MissionModel obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.consultantId);
    writer.writeString(obj.title);
    writer.writeString(obj.clientName);
    writer.writeString(obj.address);
    writer.write(obj.latitude);
    writer.write(obj.longitude);
    writer.writeInt(obj.scheduledStart.millisecondsSinceEpoch);
    writer.writeInt(obj.scheduledEnd.millisecondsSinceEpoch);
    writer.writeString(obj.status);
    writer.write(obj.contactName);
    writer.write(obj.contactPhone);
    writer.writeBool(obj.requiresSignature);
  }
}

// ─── IncidentModel ────────────────────────────────────────
class IncidentModel extends HiveObject {
  int id;
  int missionId;
  String type;
  String description;
  DateTime createdAt;

  IncidentModel({
    required this.id,
    required this.missionId,
    required this.type,
    required this.description,
    required this.createdAt,
  });
}

class IncidentModelAdapter extends TypeAdapter<IncidentModel> {
  @override
  final int typeId = 2;

  @override
  IncidentModel read(BinaryReader reader) {
    return IncidentModel(
      id: reader.readInt(),
      missionId: reader.readInt(),
      type: reader.readString(),
      description: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, IncidentModel obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.missionId);
    writer.writeString(obj.type);
    writer.writeString(obj.description);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}