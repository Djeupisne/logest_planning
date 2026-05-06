import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modèle pour le Morning Briefing quotidien du consultant
/// Fournit un résumé personnalisé de la journée
class MorningBriefing {
  final DateTime date;
  final String consultantName;
  final int totalMissions;
  final List<MissionSummary> missions;
  final WeatherInfo? weather;
  final TrafficCondition trafficCondition;
  final String? motivationalQuote;
  final Duration estimatedTravelTime;
  final Duration totalWorkTime;
  final List<String> importantNotes;

  const MorningBriefing({
    required this.date,
    required this.consultantName,
    required this.totalMissions,
    required this.missions,
    this.weather,
    this.trafficCondition = TrafficCondition.normal,
    this.motivationalQuote,
    required this.estimatedTravelTime,
    required this.totalWorkTime,
    this.importantNotes = const [],
  });

  /// Heure de début de la première mission
  DateTime? get firstMissionTime {
    if (missions.isEmpty) return null;
    return missions.first.startTime;
  }

  /// Heure de fin de la dernière mission
  DateTime? get lastMissionEndTime {
    if (missions.isEmpty) return null;
    return missions.last.endTime;
  }

  /// Nombre de missions urgentes
  int get urgentMissionsCount => missions.where((m) => m.isUrgent).length;

  /// Distance totale estimée (km)
  double get totalDistanceKm => missions.fold<double>(0, (sum, m) => sum + (m.distanceKm ?? 0));

  /// Statut de préparation
  BriefingReadiness get readiness {
    if (missions.any((m) => !m.isReady)) {
      return BriefingReadiness.incomplete;
    }
    if (urgentMissionsCount > 0) {
      return BriefingReadiness.attention;
    }
    return BriefingReadiness.ready;
  }

  /// Messages contextuels
  List<String> get contextualMessages {
    final messages = <String>[];
    
    if (weather != null) {
      if (weather!.isRainy) {
        messages.add('☔ Prévoyez un parapluie - Pluie attendue');
      } else if (weather!.temperature > 35) {
        messages.add('☀️ Forte chaleur prévue - Restez hydraté');
      }
    }
    
    if (trafficCondition == TrafficCondition.heavy) {
      messages.add('🚗 Trafic dense prévu - Partez plus tôt');
    } else if (trafficCondition == TrafficCondition.veryHeavy) {
      messages.add('🚙🚕🚗 Embouteillages importants - Départ recommandé 30min plus tôt');
    }
    
    if (firstMissionTime != null) {
      final now = DateTime.now();
      final timeUntilFirst = firstMissionTime!.difference(now);
      if (timeUntilFirst.isNegative) {
        messages.add('⚠️ Votre première mission a déjà commencé!');
      } else if (timeUntilFirst.inMinutes < 30) {
        messages.add('⏰ Première mission dans ${timeUntilFirst.inMinutes} minutes');
      }
    }
    
    if (totalMissions == 0) {
      messages.add('📅 Aucune mission prévue aujourd\'hui');
    }
    
    return messages;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'consultant_name': consultantName,
      'total_missions': totalMissions,
      'missions': missions.map((m) => m.toJson()).toList(),
      'weather': weather?.toJson(),
      'traffic_condition': trafficCondition.name,
      'motivational_quote': motivationalQuote,
      'estimated_travel_time_minutes': estimatedTravelTime.inMinutes,
      'total_work_time_minutes': totalWorkTime.inMinutes,
      'important_notes': importantNotes,
    };
  }

  factory MorningBriefing.fromJson(Map<String, dynamic> json) {
    return MorningBriefing(
      date: DateTime.parse(json['date']),
      consultantName: json['consultant_name'],
      totalMissions: json['total_missions'],
      missions: (json['missions'] as List).map((m) => MissionSummary.fromJson(m)).toList(),
      weather: json['weather'] != null ? WeatherInfo.fromJson(json['weather']) : null,
      trafficCondition: TrafficCondition.values.firstWhere(
        (e) => e.name == json['traffic_condition'],
        orElse: () => TrafficCondition.normal,
      ),
      motivationalQuote: json['motivational_quote'],
      estimatedTravelTime: Duration(minutes: json['estimated_travel_time_minutes'] ?? 0),
      totalWorkTime: Duration(minutes: json['total_work_time_minutes'] ?? 0),
      importantNotes: json['important_notes'] != null 
          ? List<String>.from(json['important_notes']) 
          : [],
    );
  }
}

/// Résumé d'une mission pour le briefing
class MissionSummary {
  final String id;
  final String clientName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final MissionStatus status;
  final bool isUrgent;
  final double? distanceKm;
  final String? contactPhone;
  final bool isReady; // Tous les détails sont-ils remplis?

  const MissionSummary({
    required this.id,
    required this.clientName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.isUrgent = false,
    this.distanceKm,
    this.contactPhone,
    this.isReady = true,
  });

  Duration get duration => endTime.difference(startTime);

  String get formattedTime {
    final format = DateFormat('HH:mm');
    return '${format.format(startTime)} - ${format.format(endTime)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'is_urgent': isUrgent,
      'distance_km': distanceKm,
      'contact_phone': contactPhone,
      'is_ready': isReady,
    };
  }

  factory MissionSummary.fromJson(Map<String, dynamic> json) {
    return MissionSummary(
      id: json['id'],
      clientName: json['client_name'],
      location: json['location'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: MissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MissionStatus.scheduled,
      ),
      isUrgent: json['is_urgent'] ?? false,
      distanceKm: json['distance_km']?.toDouble(),
      contactPhone: json['contact_phone'],
      isReady: json['is_ready'] ?? true,
    );
  }
}

/// Statut d'une mission
enum MissionStatus {
  scheduled,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
  problem,
}

/// Conditions de trafic
enum TrafficCondition {
  light,      // Fluide
  normal,     // Normal
  heavy,      // Dense
  veryHeavy,  // Très dense
}

/// Informations météo
class WeatherInfo {
  final double temperature; // en °C
  final WeatherCondition condition;
  final int humidity; // en %
  final bool isRainy;

  const WeatherInfo({
    required this.temperature,
    required this.condition,
    this.humidity = 50,
    this.isRainy = false,
  });

  String get icon {
    switch (condition) {
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.partlyCloudy:
        return '⛅';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.stormy:
        return '⛈️';
    }
  }

  String get description {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Ensoleillé';
      case WeatherCondition.partlyCloudy:
        return 'Partiellement nuageux';
      case WeatherCondition.cloudy:
        return 'Nuageux';
      case WeatherCondition.rainy:
        return 'Pluvieux';
      case WeatherCondition.stormy:
        return 'Orageux';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition.name,
      'humidity': humidity,
      'is_rainy': isRainy,
    };
  }

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      temperature: json['temperature'],
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.sunny,
      ),
      humidity: json['humidity'] ?? 50,
      isRainy: json['is_rainy'] ?? false,
    );
  }
}

/// Conditions météo
enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  stormy,
}

/// État de préparation du briefing
enum BriefingReadiness {
  ready,       // Tout est prêt
  attention,   // Attention requise (missions urgentes)
  incomplete,  // Informations manquantes
}

/// Citations motivantes pour les consultants
class MotivationalQuotes {
  static const List<String> quotes = [
    "Le succès, c'est d'aller d'échec en échec sans perdre son enthousiasme. - Winston Churchill",
    "La seule façon de faire du bon travail est d'aimer ce que vous faites. - Steve Jobs",
    "Chaque mission accomplie est une victoire de plus. - LOGEST",
    "Votre expertise fait la différence pour nos clients. - LOGEST",
    "La qualité de votre travail reflète votre professionnalisme. - LOGEST",
    "Un consultant préparé est un consultant efficace. - LOGEST",
    "Chaque jour est une nouvelle opportunité d'exceller. - LOGEST",
    "Votre engagement est notre réussite. - LOGEST",
  ];

  static String getDailyQuote(DateTime date) {
    final index = date.day % quotes.length;
    return quotes[index];
  }
}
