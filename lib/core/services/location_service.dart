import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service de géolocalisation avec gestion des permissions et respect de la vie privée
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  bool _locationPermissionGranted = false;
  DateTime? _workStartTime;
  DateTime? _workEndTime;
  bool _trackingEnabled = false;
  
  /// Définit les heures de travail pour le suivi GPS
  void setWorkHours(DateTime start, DateTime end) {
    _workStartTime = start;
    _workEndTime = end;
  }
  
  /// Vérifie si nous sommes dans les heures de travail
  bool isWithinWorkHours() {
    if (_workStartTime == null || _workEndTime == null) return true;
    final now = DateTime.now();
    return now.isAfter(_workStartTime!) && now.isBefore(_workEndTime!);
  }
  
  /// Demande la permission de localisation
  Future<bool> requestLocationPermission() async {
    var status = await Geolocator.checkPermission();
    
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
      if (status == LocationPermission.denied) {
        _locationPermissionGranted = false;
        return false;
      }
    }
    
    if (status == LocationPermission.deniedForever) {
      _locationPermissionGranted = false;
      // Ouvrir les paramètres pour que l'utilisateur puisse activer manuellement
      await openAppSettings();
      return false;
    }
    
    _locationPermissionGranted = true;
    return true;
  }
  
  /// Active le suivi GPS (seulement pendant les heures de travail)
  Future<bool> enableTracking() async {
    if (!isWithinWorkHours()) {
      debugPrint('Le suivi GPS n\'est autorisé que pendant les heures de travail');
      return false;
    }
    
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      _trackingEnabled = false;
      return false;
    }
    
    _trackingEnabled = true;
    return true;
  }
  
  /// Désactive le suivi GPS
  void disableTracking() {
    _trackingEnabled = false;
  }
  
  /// Vérifie si le suivi est activé
  bool get isTrackingEnabled => _trackingEnabled && isWithinWorkHours();
  
  /// Obtient la position actuelle
  Future<Position?> getCurrentPosition() async {
    if (!_trackingEnabled) {
      debugPrint('Le suivi GPS n\'est pas activé');
      return null;
    }
    
    if (!isWithinWorkHours()) {
      debugPrint('Hors des heures de travail - suivi GPS désactivé');
      return null;
    }
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Erreur de géolocalisation: $e');
      return null;
    }
  }
  
  /// Flux continu de positions (pour le suivi en temps réel)
  Stream<Position?> getPositionStream() async* {
    if (!_trackingEnabled) {
      yield null;
      return;
    }
    
    if (!isWithinWorkHours()) {
      yield null;
      return;
    }
    
    try {
      await for (final position in Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Mise à jour tous les 10 mètres
        ),
      )) {
        yield position;
      }
    } catch (e) {
      debugPrint('Erreur dans le flux de position: $e');
      yield null;
    }
  }
  
  /// Calcule la distance entre deux points (en mètres)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  /// Vérifie si l'utilisateur est proche d'une destination
  bool isNearDestination(double userLat, double userLon, double destLat, double destLon, {double radius = 50}) {
    final distance = calculateDistance(userLat, userLon, destLat, destLon);
    return distance <= radius;
  }
}
