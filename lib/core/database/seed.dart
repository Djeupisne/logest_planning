// lib/core/database/seed.dart
import 'package:drift/drift.dart' as drift;
import 'app_database.dart';
import 'tables/users_table.dart';
import 'tables/missions_table.dart';
import 'tables/incidents_table.dart';

class DatabaseSeeder {
  static Future<void> seed(AppDatabase db) async {
    // Vérifier si déjà peuplé
    final existingUsers = await db.getAllUsers();
    if (existingUsers.isNotEmpty) return;

    // Insertion des utilisateurs
    final userIds = <int>[];
    userIds.add(await db.insertUser(UsersTableCompanion(
      email: drift.Value("consultant@logest.com"),
      fullName: drift.Value("Jean Dupont"),
      role: drift.Value("consultant"),
      password: drift.Value("password"),
      phone: drift.Value("+235 66 12 34 56"),
      specialty: drift.Value("Réseaux & Infrastructure"),
      createdAt: drift.Value(DateTime.now()),
    )));
    userIds.add(await db.insertUser(UsersTableCompanion(
      email: drift.Value("planner@logest.com"),
      fullName: drift.Value("Marie N'Djamena"),
      role: drift.Value("planner"),
      password: drift.Value("password"),
      phone: drift.Value("+235 66 23 45 67"),
      specialty: drift.Value("Planification"),
      createdAt: drift.Value(DateTime.now()),
    )));
    userIds.add(await db.insertUser(UsersTableCompanion(
      email: drift.Value("direction@logest.com"),
      fullName: drift.Value("Ali Mahamat"),
      role: drift.Value("director"),
      password: drift.Value("password"),
      phone: drift.Value("+235 66 34 56 78"),
      specialty: drift.Value("Management"),
      createdAt: drift.Value(DateTime.now()),
    )));
    userIds.add(await db.insertUser(UsersTableCompanion(
      email: drift.Value("fatima@logest.com"),
      fullName: drift.Value("Fatima Hassan"),
      role: drift.Value("consultant"),
      password: drift.Value("password"),
      phone: drift.Value("+235 66 45 67 89"),
      specialty: drift.Value("Formation"),
      createdAt: drift.Value(DateTime.now()),
    )));

    // Insertion des missions
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    await db.insertMission(MissionsTableCompanion(
      consultantId: drift.Value(userIds[0]),
      title: drift.Value("Installation réseau"),
      clientName: drift.Value("Banque Sahélo-Saharienne"),
      address: drift.Value("Avenue Charles de Gaulle, N'Djamena"),
      latitude: drift.Value(12.1348),
      longitude: drift.Value(15.0557),
      scheduledStart: drift.Value(today.add(const Duration(hours: 9))),
      scheduledEnd: drift.Value(today.add(const Duration(hours: 12))),
      status: drift.Value("en_route"),
      contactName: drift.Value("M. Ibrahim"),
      contactPhone: drift.Value("+235 66 12 34 56"),
      requiresSignature: drift.Value(false),
      createdAt: drift.Value(now),
    ));

    await db.insertMission(MissionsTableCompanion(
      consultantId: drift.Value(userIds[0]),
      title: drift.Value("Consultation IT"),
      clientName: drift.Value("Société Tchadienne"),
      address: drift.Value("Quartier Chagoua, N'Djamena"),
      latitude: drift.Value(12.1250),
      longitude: drift.Value(15.0650),
      scheduledStart: drift.Value(today.add(const Duration(hours: 15))),
      scheduledEnd: drift.Value(today.add(const Duration(hours: 18))),
      status: drift.Value("planned"),
      contactName: drift.Value("M. Oumar"),
      contactPhone: drift.Value("+235 66 45 67 89"),
      requiresSignature: drift.Value(true),
      createdAt: drift.Value(now),
    ));

    await db.insertMission(MissionsTableCompanion(
      consultantId: drift.Value(userIds[3]),
      title: drift.Value("Formation Excel"),
      clientName: drift.Value("Ministère des Finances"),
      address: drift.Value("Quartier Diguel, N'Djamena"),
      latitude: drift.Value(12.1200),
      longitude: drift.Value(15.0500),
      scheduledStart: drift.Value(today.add(const Duration(hours: 14))),
      scheduledEnd: drift.Value(today.add(const Duration(hours: 17))),
      status: drift.Value("in_progress"),
      contactName: drift.Value("Mme. Fatima"),
      contactPhone: drift.Value("+235 66 23 45 67"),
      requiresSignature: drift.Value(false),
      createdAt: drift.Value(now),
    ));
  }
}
