import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../models/connectivity_status.dart';

/// Service de surveillance de la connectivité réseau
/// Détecte WiFi, 4G/3G/2G, et absence de réseau
/// Avec évaluation de la qualité du signal
class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<bool>? _internetSubscription;
  
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  ConnectivityStatus get currentStatus => _currentStatus;
  
  bool _isDataSaverMode = false;
  bool get isDataSaverMode => _isDataSaverMode;
  
  /// Initialiser le moniteur de connectivité
  Future<void> initialize() async {
    // Statut initial
    _currentStatus = await _evaluateConnectivity();
    _statusController.add(_currentStatus);
    
    // Écouter les changements de type de connexion
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final newStatus = await _evaluateConnectivity();
        if (newStatus != _currentStatus) {
          _currentStatus = newStatus;
          _statusController.add(newStatus);
          
          // Log pour débogage
          print('[ConnectivityMonitor] Changement: ${newStatus.type}');
        }
      },
    );
    
    // Vérifier périodiquement la qualité de la connexion
    _startPeriodicCheck();
  }
  
  /// Évaluer la connectivité actuelle
  Future<ConnectivityStatus> _evaluateConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return ConnectivityStatus(
          type: ConnectivityType.offline,
          hasInternet: false,
          quality: SignalQuality.none,
        );
      }
      
      // Vérifier si internet est réellement accessible
      final hasInternet = await _connectionChecker.hasConnection;
      
      if (!hasInternet) {
        return ConnectivityStatus(
          type: ConnectivityType.connectedNoInternet,
          hasInternet: false,
          quality: SignalQuality.none,
        );
      }
      
      // Déterminer le type et la qualité
      ConnectivityType connType;
      SignalQuality quality;
      
      if (results.contains(ConnectivityResult.wifi)) {
        connType = ConnectivityType.wifi;
        quality = SignalQuality.excellent; // WiFi généralement stable
      } else if (results.contains(ConnectivityResult.mobile)) {
        connType = ConnectivityType.mobile;
        quality = await _measureMobileSignalQuality();
      } else {
        connType = ConnectivityType.other;
        quality = SignalQuality.unknown;
      }
      
      return ConnectivityStatus(
        type: connType,
        hasInternet: true,
        quality: quality,
      );
    } catch (e) {
      print('[ConnectivityMonitor] Erreur évaluation: $e');
      return ConnectivityStatus(
        type: ConnectivityType.unknown,
        hasInternet: false,
        quality: SignalQuality.unknown,
      );
    }
  }
  
  /// Mesurer la qualité du signal mobile
  Future<SignalQuality> _measureMobileSignalQuality() async {
    try {
      // Test de latence simple
      final stopwatch = Stopwatch()..start();
      final hasConnection = await _connectionChecker.hasConnection;
      stopwatch.stop();
      
      final latency = stopwatch.elapsedMilliseconds;
      
      if (!hasConnection) return SignalQuality.none;
      if (latency < 100) return SignalQuality.excellent;
      if (latency < 300) return SignalQuality.good;
      if (latency < 1000) return SignalQuality.fair;
      return SignalQuality.poor;
    } catch (e) {
      return SignalQuality.unknown;
    }
  }
  
  /// Démarrer les vérifications périodiques
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(seconds: 30), (_) async {
      final status = await _evaluateConnectivity();
      if (status != _currentStatus) {
        _currentStatus = status;
        _statusController.add(status);
      }
    });
  }
  
  /// Activer/désactiver le mode économie de données
  void setDataSaverMode(bool enabled) {
    _isDataSaverMode = enabled;
    print('[ConnectivityMonitor] Mode économie de données: $enabled');
  }
  
  /// Vérifier si connecté
  static Future<bool> isConnected() async {
    final monitor = ConnectivityMonitor();
    return monitor.currentStatus.hasInternet;
  }
  
  /// Vérifier si hors ligne
  static Future<bool> isOffline() async {
    final monitor = ConnectivityMonitor();
    return !monitor.currentStatus.hasInternet;
  }
  
  /// Vérifier si réseau faible
  static Future<bool> isWeakNetwork() async {
    final monitor = ConnectivityMonitor();
    return monitor.currentStatus.quality == SignalQuality.poor ||
           monitor.currentStatus.quality == SignalQuality.fair;
  }
  
  /// Nettoyer les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _statusController.close();
  }
}
```

## Modèle de Statut de Connectivité

```dart
// lib/models/connectivity_status.dart

/// Type de connexion réseau
enum ConnectivityType {
  wifi,
  mobile,      // 4G/3G/2G
  ethernet,
  other,
  connectedNoInternet, // Routeur sans internet
  offline,
  unknown,
}

/// Qualité du signal
enum SignalQuality {
  excellent,   // < 100ms latency
  good,        // 100-300ms
  fair,        // 300-1000ms
  poor,        // > 1000ms
  none,        // Pas de connexion
  unknown,
}

/// Statut complet de connectivité
class ConnectivityStatus {
  final ConnectivityType type;
  final bool hasInternet;
  final SignalQuality quality;
  
  const ConnectivityStatus({
    required this.type,
    required this.hasInternet,
    required this.quality,
  });
  
  /// Est-ce qu'on peut faire une sync complète ?
  bool get canSyncFully => hasInternet && quality != SignalQuality.poor;
  
  /// Devrait-on utiliser le mode économie de données ?
  bool get shouldUseDataSaver => 
      !hasInternet || 
      quality == SignalQuality.poor || 
      quality == SignalQuality.fair;
  
  /// Couleur indicative pour l'UI
  String get colorCode {
    if (!hasInternet) return '#EF4444'; // Rouge
    switch (quality) {
      case SignalQuality.excellent: return '#10B981'; // Vert
      case SignalQuality.good: return '#3B82F6'; // Bleu
      case SignalQuality.fair: return '#F59E0B'; // Orange
      case SignalQuality.poor: return '#EF4444'; // Rouge
      default: return '#9CA3AF'; // Gris
    }
  }
  
  /// Label texte pour l'UI
  String get label {
    if (!hasInternet) return 'Hors ligne';
    
    switch (type) {
      case ConnectivityType.wifi:
        return 'WiFi ${quality.label}';
      case ConnectivityType.mobile:
        return '4G/3G ${quality.label}';
      case ConnectivityType.connectedNoInternet:
        return 'Connecté (pas d\'internet)';
      default:
        return 'Connecté';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityStatus &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          hasInternet == other.hasInternet &&
          quality == other.quality;
  
  @override
  int get hashCode => type.hashCode ^ hasInternet.hashCode ^ quality.hashCode;
}

extension SignalQualityExtension on SignalQuality {
  String get label {
    switch (this) {
      case SignalQuality.excellent: return 'Excellent';
      case SignalQuality.good: return 'Bon';
      case SignalQuality.fair: return 'Moyen';
      case SignalQuality.poor: return 'Faible';
      default: return 'Inconnu';
    }
  }
}
```

## Utilisation

```dart
// Initialisation dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final connectivityMonitor = ConnectivityMonitor();
  await connectivityMonitor.initialize();
  
  runApp(MyApp());
}

// Écouter les changements dans un widget
class ConnectivityAwareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: ConnectivityMonitor().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus(
          type: ConnectivityType.unknown,
          hasInternet: false,
          quality: SignalQuality.unknown,
        );
        
        return Column(
          children: [
            ConnectivityBanner(status: status),
            // Reste de l'UI
          ],
        );
      },
    );
  }
}
