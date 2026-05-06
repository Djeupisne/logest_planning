/// Type de connexion réseau
enum ConnectivityType {
  wifi,
  mobile, // 4G/3G/2G
  ethernet,
  other,
  connectedNoInternet, // Routeur sans internet
  offline,
  unknown,
}

/// Qualité du signal
enum SignalQuality {
  excellent, // < 100ms latency
  good, // 100-300ms
  fair, // 300-1000ms
  poor, // > 1000ms
  none, // Pas de connexion
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
      case SignalQuality.excellent:
        return '#10B981'; // Vert
      case SignalQuality.good:
        return '#3B82F6'; // Bleu
      case SignalQuality.fair:
        return '#F59E0B'; // Orange
      case SignalQuality.poor:
        return '#EF4444'; // Rouge
      default:
        return '#9CA3AF'; // Gris
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
      case SignalQuality.excellent:
        return 'Excellent';
      case SignalQuality.good:
        return 'Bon';
      case SignalQuality.fair:
        return 'Moyen';
      case SignalQuality.poor:
        return 'Faible';
      default:
        return 'Inconnu';
    }
  }
}
