import 'package:hive_flutter/hive_flutter.dart';
import 'hive_models.dart';

class HiveService {
  static const String usersBox = 'users';
  static const String missionsBox = 'missions';
  static const String incidentsBox = 'incidents';

  static Future<void> init() async {
    await Hive.initFlutter(); // gère web + mobile sans path_provider

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(MissionModelAdapter());
    Hive.registerAdapter(IncidentModelAdapter());

    await Hive.openBox<UserModel>(usersBox);
    await Hive.openBox<MissionModel>(missionsBox);
    await Hive.openBox<IncidentModel>(incidentsBox);

    await _seedData();
  }

  static Future<void> _seedData() async {
    final userBox = Hive.box<UserModel>(usersBox);
    if (userBox.isEmpty) {
      int id = 1;
      await userBox.add(UserModel(id: id++, email: "consultant@logest.com", fullName: "Jean Dupont", role: "consultant", password: "password", phone: "+235 66 12 34 56"));
      await userBox.add(UserModel(id: id++, email: "planner@logest.com", fullName: "Marie N'Djamena", role: "planner", password: "password", phone: "+235 66 23 45 67"));
      await userBox.add(UserModel(id: id++, email: "direction@logest.com", fullName: "Ali Mahamat", role: "director", password: "password", phone: "+235 66 34 56 78"));
      await userBox.add(UserModel(id: id++, email: "fatima@logest.com", fullName: "Fatima Hassan", role: "consultant", password: "password", phone: "+235 66 45 67 89"));
    }

    final missionBox = Hive.box<MissionModel>(missionsBox);
    if (missionBox.isEmpty) {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);

      await missionBox.add(MissionModel(
        id: 1, consultantId: 1, title: "Installation réseau", clientName: "Banque Sahélo-Saharienne",
        address: "Avenue Charles de Gaulle, N'Djamena", latitude: 12.1348, longitude: 15.0557,
        scheduledStart: d.add(const Duration(hours: 9)), scheduledEnd: d.add(const Duration(hours: 12)),
        status: "en_route", contactName: "M. Ibrahim", contactPhone: "+235 66 12 34 56", requiresSignature: false,
      ));
      await missionBox.add(MissionModel(
        id: 2, consultantId: 1, title: "Consultation IT", clientName: "Société Tchadienne",
        address: "Quartier Chagoua, N'Djamena", latitude: 12.1250, longitude: 15.0650,
        scheduledStart: d.add(const Duration(hours: 15)), scheduledEnd: d.add(const Duration(hours: 18)),
        status: "planned", contactName: "M. Oumar", contactPhone: "+235 66 45 67 89", requiresSignature: true,
      ));
      await missionBox.add(MissionModel(
        id: 3, consultantId: 4, title: "Formation Excel", clientName: "Ministère des Finances",
        address: "Quartier Diguel, N'Djamena", latitude: 12.1200, longitude: 15.0500,
        scheduledStart: d.add(const Duration(hours: 14)), scheduledEnd: d.add(const Duration(hours: 17)),
        status: "in_progress", contactName: "Mme. Fatima", contactPhone: "+235 66 23 45 67", requiresSignature: false,
      ));
    }
  }

  static Box<UserModel> get users => Hive.box<UserModel>(usersBox);
  static Box<MissionModel> get missions => Hive.box<MissionModel>(missionsBox);
  static Box<IncidentModel> get incidents => Hive.box<IncidentModel>(incidentsBox);
}