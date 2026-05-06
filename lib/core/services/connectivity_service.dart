import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/security_sync_service.dart';

/// Service de gestion de la connectivité réseau
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  
  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = SyncService();
  bool _isOnline = true;
  List<void Function(bool)> _listeners = [];
  
  /// Initialise le service de connectivité
  Future<void> init() async {
    // Vérifier l'état initial
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    
    // Écouter les changements de connectivité
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      debugPrint('Changement de connectivité: ${_isOnline ? "EN LIGNE" : "HORS LIGNE"}');
      for (final listener in _listeners) {
        listener(_isOnline);
      }
      
      // Si on revient en ligne, synchroniser les données en attente
      if (_isOnline && wasOnline == false) {
        _performSync();
      }
    }
  }
  
  /// Vérifie si l'appareil est en ligne
  bool get isOnline => _isOnline;
  
  /// Ajoute un écouteur pour les changements de connectivité
  void addListener(void Function(bool isOnline) listener) {
    _listeners.add(listener);
  }
  
  /// Supprime un écouteur
  void removeListener(void Function(bool isOnline) listener) {
    _listeners.remove(listener);
  }
  
  /// Effectue la synchronisation des données en attente
  Future<void> _performSync() async {
    if (!_syncService.hasPendingOperations()) {
      debugPrint('Aucune opération en attente de synchronisation');
      return;
    }
    
    debugPrint('Début de la synchronisation - ${_syncService.pendingCount()} opérations en attente');
    
    final pendingOps = _syncService.getPendingOperations();
    for (final op in pendingOps) {
      try {
        await _syncOperation(op);
        await _syncService.markAsSynced(op['id'] as int);
        debugPrint('Opération synchronisée: ${op['type']}');
      } catch (e) {
        debugPrint('Erreur de synchronisation pour ${op['type']}: $e');
      }
    }
    
    await _syncService.clearSyncedOperations();
    debugPrint('Synchronisation terminée');
  }
  
  /// Traite une opération de synchronisation individuelle
  Future<void> _syncOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final data = operation['data'] as Map<String, dynamic>;
    
    switch (type) {
      case 'mission_update':
        await _syncMissionUpdate(data);
        break;
      case 'incident_report':
        await _syncIncidentReport(data);
        break;
      case 'mission_report':
        await _syncMissionReport(data);
        break;
      default:
        debugPrint('Type d\'opération inconnu: $type');
    }
  }
  
  /// Synchronise une mise à jour de mission
  Future<void> _syncMissionUpdate(Map<String, dynamic> data) async {
    final missionId = data['missionId'] as int;
    final status = data['status'] as String;
    // TODO: Appeler l'API backend pour mettre à jour la mission
    debugPrint('API: Mise à jour mission $missionId avec statut: $status');
    // Simuler un appel API
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Synchronise un rapport d'incident
  Future<void> _syncIncidentReport(Map<String, dynamic> data) async {
    final missionId = data['missionId'] as int;
    final type = data['type'] as String;
    final description = data['description'] as String;
    // TODO: Appeler l'API backend pour envoyer l'incident
    debugPrint('API: Incident signalé pour mission $missionId: $type - $description');
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Synchronise un rapport de mission
  Future<void> _syncMissionReport(Map<String, dynamic> data) async {
    final missionId = data['missionId'] as int;
    final comments = data['comments'] as String;
    final signaturePath = data['signaturePath'] as String?;
    // TODO: Appeler l'API backend pour envoyer le rapport
    debugPrint('API: Rapport envoyé pour mission $missionId: $comments');
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Force une synchronisation manuelle
  Future<bool> forceSync() async {
    if (!_isOnline) {
      debugPrint('Impossible de synchroniser: hors ligne');
      return false;
    }
    
    await _performSync();
    return true;
  }
}
