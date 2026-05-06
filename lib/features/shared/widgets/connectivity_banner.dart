import 'package:flutter/material.dart';
import '../models/connectivity_status.dart';

/// Bandeau de statut de connexion réseau
/// Affiche en haut de l'application le statut actuel
/// Avec code couleur et actions rapides
class ConnectivityBanner extends StatelessWidget {
  final ConnectivityStatus status;
  final VoidCallback? onSyncTap;
  final VoidCallback? onSettingsTap;

  const ConnectivityBanner({
    Key? key,
    required this.status,
    this.onSyncTap,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ne rien afficher si connexion excellente
    if (status.hasInternet && status.quality == SignalQuality.excellent) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Icône de statut
            Icon(
              _getIcon(),
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            
            // Texte de statut
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMessage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (status.quality == SignalQuality.poor || 
                      status.quality == SignalQuality.fair)
                    Text(
                      'Mode économie de données activé',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Bouton Sync manuelle (si hors ligne)
            if (!status.hasInternet && onSyncTap != null) ...[
              TextButton.icon(
                onPressed: onSyncTap,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Sync',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            // Bouton Paramètres
            if (onSettingsTap != null)
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: onSettingsTap,
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!status.hasInternet) {
      return const Color(0xFFEF4444); // Rouge
    }
    
    switch (status.quality) {
      case SignalQuality.excellent:
        return const Color(0xFF10B981); // Vert
      case SignalQuality.good:
        return const Color(0xFF3B82F6); // Bleu
      case SignalQuality.fair:
        return const Color(0xFFF59E0B); // Orange
      case SignalQuality.poor:
        return const Color(0xFFEF4444); // Rouge
      default:
        return const Color(0xFF9CA3AF); // Gris
    }
  }

  IconData _getIcon() {
    if (!status.hasInternet) {
      return Icons.wifi_off;
    }
    
    switch (status.type) {
      case ConnectivityType.wifi:
        return Icons.wifi;
      case ConnectivityType.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityType.ethernet:
        return Icons.lan;
      default:
        return Icons.wifi;
    }
  }

  String _getMessage() {
    if (!status.hasInternet) {
      return 'Hors ligne - Certaines fonctionnalités sont limitées';
    }
    
    if (status.quality == SignalQuality.poor) {
      return 'Réseau faible - Mode économie activé';
    }
    
    if (status.quality == SignalQuality.fair) {
      return 'Réseau moyen - Optimisation activée';
    }
    
    return status.label;
  }
}
