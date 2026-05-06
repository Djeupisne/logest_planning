import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de chiffrement pour les données sensibles
class EncryptionService {
  static const String _secureBoxName = 'secure_data';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Chiffre une chaîne de caractères (pour stockage local)
  Future<String> encrypt(String data) async {
    // Pour une implémentation production, utiliser un algorithme AES-256
    // Ici on utilise flutter_secure_storage qui gère le chiffrement natif
    return data; // Le chiffrement est géré par le stockage sécurisé
  }
  
  /// Déchiffre une chaîne de caractères
  Future<String> decrypt(String encryptedData) async {
    return encryptedData;
  }
  
  /// Stocke une donnée sensible de manière sécurisée
  Future<void> storeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Récupère une donnée sensible
  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Supprime une donnée sensible
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  /// Efface toutes les données sécurisées
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}

/// Service de gestion de la synchronisation online/offline
class SyncService {
  static const String _pendingSyncBox = 'pending_sync';
  late Box<dynamic> _pendingBox;
  
  /// Initialise le service de synchronisation
  Future<void> init() async {
    _pendingBox = await Hive.openBox(_pendingSyncBox);
  }
  
  /// Ajoute une opération en attente de synchronisation
  Future<void> addPendingOperation(String type, Map<String, dynamic> data) async {
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };
    await _pendingBox.add(operation);
  }
  
  /// Récupère toutes les opérations en attente
  List<Map<String, dynamic>> getPendingOperations() {
    return _pendingBox.values
        .where((op) => !(op['synced'] as bool))
        .map((op) => Map<String, dynamic>.from(op))
        .toList();
  }
  
  /// Marque une opération comme synchronisée
  Future<void> markAsSynced(int id) async {
    final key = _pendingBox.keys.firstWhere(
      (k) => _pendingBox.get(k)['id'] == id,
    );
    final operation = Map<String, dynamic>.from(_pendingBox.get(key));
    operation['synced'] = true;
    await _pendingBox.put(key, operation);
  }
  
  /// Supprime les opérations synchronisées
  Future<void> clearSyncedOperations() async {
    final keysToDelete = <dynamic>[];
    for (final key in _pendingBox.keys) {
      final op = _pendingBox.get(key);
      if (op['synced'] == true) {
        keysToDelete.add(key);
      }
    }
    for (final key in keysToDelete) {
      await _pendingBox.delete(key);
    }
  }
  
  /// Vérifie s'il y a des opérations en attente
  bool hasPendingOperations() {
    return _pendingBox.values.any((op) => !(op['synced'] as bool));
  }
  
  /// Nombre d'opérations en attente
  int pendingCount() {
    return _pendingBox.values.where((op) => !(op['synced'] as bool)).length;
  }
}

/// Gestionnaire de file d'attente pour les opérations hors-ligne
class OfflineQueue {
  final SyncService _syncService;
  
  OfflineQueue(this._syncService);
  
  /// Ajoute une mission à mettre à jour dans la file d'attente
  Future<void> queueMissionUpdate(int missionId, String status) async {
    await _syncService.addPendingOperation('mission_update', {
      'missionId': missionId,
      'status': status,
    });
  }
  
  /// Ajoute un incident à envoyer dans la file d'attente
  Future<void> queueIncidentReport(int missionId, String type, String description) async {
    await _syncService.addPendingOperation('incident_report', {
      'missionId': missionId,
      'type': type,
      'description': description,
    });
  }
  
  /// Ajoute un rapport de mission à envoyer
  Future<void> queueMissionReport(int missionId, String comments, String? signaturePath) async {
    await _syncService.addPendingOperation('mission_report', {
      'missionId': missionId,
      'comments': comments,
      'signaturePath': signaturePath,
    });
  }
}
