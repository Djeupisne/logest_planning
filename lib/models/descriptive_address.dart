import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modèle pour une adresse descriptive adaptée au contexte tchadien
/// Permet de décrire un lieu par des points de repère plutôt que par une adresse postale standard
class DescriptiveAddress {
  final String? streetName; // Optionnel : nom de rue si connu
  final String? buildingNumber; // Optionnel : numéro de bâtiment
  final String neighborhood; // Quartier (ex: "Moursal", "Chagoua")
  final String city; // Ville (ex: "N'Djaména")
  final List<String> landmarks; // Points de repère (ex: ["Près de la mosquée", "En face du marché"])
  final String? additionalInfo; // Informations complémentaires
  final double? latitude;
  final double? longitude;
  final String? landmarkImageUrl; // URL d'une image du point de repère

  const DescriptiveAddress({
    this.streetName,
    this.buildingNumber,
    required this.neighborhood,
    required this.city,
    this.landmarks = const [],
    this.additionalInfo,
    this.latitude,
    this.longitude,
    this.landmarkImageUrl,
  });

  /// Formate l'adresse pour affichage humain
  String get formattedAddress {
    final buffer = StringBuffer();
    
    if (buildingNumber != null && streetName != null) {
      buffer.write('$buildingNumber $streetName, ');
    } else if (streetName != null) {
      buffer.write('$streetName, ');
    }
    
    buffer.write('$neighborhood, $city');
    
    if (landmarks.isNotEmpty) {
      buffer.write(' (${landmarks.join(", ")})');
    }
    
    if (additionalInfo != null) {
      buffer.write(' - $additionalInfo');
    }
    
    return buffer.toString();
  }

  /// Formate l'adresse pour GPS
  String get gpsFormat {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return '';
  }

  /// Vérifie si l'adresse a des coordonnées GPS
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Vérifie si l'adresse a des points de repère
  bool get hasLandmarks => landmarks.isNotEmpty;

  /// Convertit en Map pour sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'street_name': streetName,
      'building_number': buildingNumber,
      'neighborhood': neighborhood,
      'city': city,
      'landmarks': landmarks,
      'additional_info': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
      'landmark_image_url': landmarkImageUrl,
    };
  }

  /// Crée une instance depuis JSON
  factory DescriptiveAddress.fromJson(Map<String, dynamic> json) {
    return DescriptiveAddress(
      streetName: json['street_name'],
      buildingNumber: json['building_number'],
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      landmarks: json['landmarks'] != null 
          ? List<String>.from(json['landmarks']) 
          : [],
      additionalInfo: json['additional_info'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      landmarkImageUrl: json['landmark_image_url'],
    );
  }

  @override
  String toString() => formattedAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DescriptiveAddress &&
        other.streetName == streetName &&
        other.buildingNumber == buildingNumber &&
        other.neighborhood == neighborhood &&
        other.city == city &&
        other.landmarks.equals(landmarks) &&
        other.additionalInfo == additionalInfo &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(
        streetName,
        buildingNumber,
        neighborhood,
        city,
        Object.hashAll(landmarks),
        additionalInfo,
        latitude,
        longitude,
      );
}

/// Extension pour comparer deux listes de strings
extension ListCompare<T> on List<T> {
  bool equals(List<T> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}

/// Enum pour les types de points de repère courants au Tchad
enum LandmarkType {
  mosque,
  church,
  market,
  school,
  hospital,
  governmentBuilding,
  shop,
  restaurant,
  gasStation,
  bank,
  hotel,
  roundabout,
  busStop,
  other,
}

/// Classe utilitaire pour gérer les points de repère
class LandmarkHelper {
  static const Map<LandmarkType, String> landmarkLabels = {
    LandmarkType.mosque: 'Mosquée',
    LandmarkType.church: 'Église',
    LandmarkType.market: 'Marché',
    LandmarkType.school: 'École',
    LandmarkType.hospital: 'Hôpital',
    LandmarkType.governmentBuilding: 'Bâtiment gouvernemental',
    LandmarkType.shop: 'Boutique',
    LandmarkType.restaurant: 'Restaurant',
    LandmarkType.gasStation: 'Station-service',
    LandmarkType.bank: 'Banque',
    LandmarkType.hotel: 'Hôtel',
    LandmarkType.roundabout: 'Rond-point',
    LandmarkType.busStop: 'Arrêt de bus',
    LandmarkType.other: 'Autre',
  };

  static const Map<LandmarkType, IconData> landmarkIcons = {
    LandmarkType.mosque: Icons.place_outlined,
    LandmarkType.church: Icons.place_outlined,
    LandmarkType.market: Icons.shopping_cart_outlined,
    LandmarkType.school: Icons.school_outlined,
    LandmarkType.hospital: Icons.local_hospital_outlined,
    LandmarkType.governmentBuilding: Icons.account_balance_outlined,
    LandmarkType.shop: Icons.store_outlined,
    LandmarkType.restaurant: Icons.restaurant_outlined,
    LandmarkType.gasStation: Icons.local_gas_station_outlined,
    LandmarkType.bank: Icons.account_balance_outlined,
    LandmarkType.hotel: Icons.hotel_outlined,
    LandmarkType.roundabout: Icons.circle_outlined,
    LandmarkType.busStop: Icons.directions_bus_outlined,
    LandmarkType.other: Icons.help_outline,
  };

  static String getLabel(LandmarkType type) => landmarkLabels[type] ?? 'Autre';
  static IconData getIcon(LandmarkType type) => landmarkIcons[type] ?? Icons.help_outline;
  
  /// Liste des quartiers courants à N'Djaména
  static const List<String> ndjamenaNeighborhoods = [
    'Moursal',
    'Chagoua',
    'Dembé',
    'Farak',
    'Goudji',
    'Klékou',
    'Moursal I',
    'Moursal II',
    'N\'Gueli',
    'Omnisports',
    'Paris C',
    'Port',
    'Ridina',
    'Sabangali',
    'Toukra',
    'Walia',
    'Zamité',
  ];

  /// Suggestions de points de repère courants
  static const List<String> commonLandmarks = [
    'Près de la Grande Mosquée',
    'En face du Marché Central',
    'À côté de l\'Hôpital de Référence',
    'Derrière le Lycée Féminin',
    'Près du Rond-point De Gaulle',
    'En face de la Cathédrale',
    'À côté de la Station Total',
    'Près du Palais des Congrès',
    'En face du Siège de la SDE',
    'À côté du Marché Dembé',
  ];
}
