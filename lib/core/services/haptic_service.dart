import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// Service de feedback haptique pour améliorer l'UX
/// Fournit des vibrations contextuelles pour les interactions utilisateur
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Vérifie si le vibration est disponible
  Future<bool> get isVibrationAvailable async {
    try {
      final available = await Vibration.hasVibrator();
      return available ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Feedback léger - pour les clics boutons
  Future<void> lightClick() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 10);
      } catch (e) {
        // Ignore si non disponible
      }
    }
  }

  /// Feedback moyen - pour les validations
  Future<void> mediumTap() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 30);
      } catch (e) {
        // Ignore si non disponible
      }
    }
  }

  /// Feedback fort - pour les alertes importantes
  Future<void> heavyImpact() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (e) {
        // Ignore si non disponible
      }
    }
  }

  /// Succès - mission complétée, sauvegarde réussie
  Future<void> success() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 50, 50, 50], intensities: [0, 128, 0, 128]);
      } catch (e) {
        await Vibration.vibrate(duration: 100);
      }
    }
  }

  /// Erreur - validation échouée, champ requis manquant
  Future<void> error() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 100, 50, 100], intensities: [0, 255, 0, 255]);
      } catch (e) {
        await Vibration.vibrate(duration: 200);
      }
    }
  }

  /// Warning - attention nécessaire
  Future<void> warning() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 75, 50, 75, 50, 75], intensities: [0, 180, 0, 180, 0, 180]);
      } catch (e) {
        await Vibration.vibrate(duration: 150);
      }
    }
  }

  /// Notification - nouvelle mission, message reçu
  Future<void> notification() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 100, 100, 100], intensities: [0, 128, 0, 128]);
      } catch (e) {
        await Vibration.vibrate(duration: 150);
      }
    }
  }

  /// Changement de statut de mission
  Future<void> statusChange() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 40);
      } catch (e) {
        // Ignore
      }
    }
  }

  /// Signature électronique validée
  Future<void> signatureValidated() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 30, 30, 30, 30, 30], intensities: [0, 100, 0, 100, 0, 100]);
      } catch (e) {
        await success();
      }
    }
  }

  /// Drag & Drop - début du déplacement
  Future<void> dragStart() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 20);
      } catch (e) {
        // Ignore
      }
    }
  }

  /// Drag & Drop - dépôt réussi
  Future<void> dragDrop() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(pattern: [0, 40], intensities: [0, 200]);
      } catch (e) {
        await mediumTap();
      }
    }
  }

  /// Refresh pull-to-refresh
  Future<void> refresh() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 60);
      } catch (e) {
        // Ignore
      }
    }
  }

  /// Bouton d'action principale pressé
  Future<void> primaryAction() async {
    if (await isVibrationAvailable) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (e) {
        // Ignore
      }
    }
  }

  /// Confirmation avec pattern personnalisé
  Future<void> confirm({int count = 2, int duration = 50}) async {
    if (await isVibrationAvailable) {
      try {
        final pattern = <int>[0];
        final intensities = <int>[0];
        for (int i = 0; i < count; i++) {
          pattern.addAll([duration, 30]);
          intensities.addAll([200, 0]);
        }
        pattern.removeLast();
        intensities.removeLast();
        await Vibration.vibrate(pattern: pattern, intensities: intensities);
      } catch (e) {
        await Vibration.vibrate(duration: duration * count);
      }
    }
  }
}

/// Extension pour ajouter le feedback haptique aux widgets
extension HapticFeedbackExtension on Widget {
  /// Enveloppe le widget avec un GestureDetector qui fournit un feedback haptique
  Widget withHaptic({VoidCallback? onTap, Function()? onLongPress}) {
    return GestureDetector(
      onTap: () {
        HapticService().lightClick();
        onTap?.call();
      },
      onLongPress: () {
        HapticService().mediumTap();
        onLongPress?.call();
      },
      child: this,
    );
  }
}

/// Bouton avec feedback haptique intégré
class HapticButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;
  final ButtonType type;

  enum ButtonType { elevated, outlined, text }

  const HapticButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.type = ButtonType.elevated,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: enabled ? _handlePress : null,
          child: child,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: enabled ? _handlePress : null,
          child: child,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: enabled ? _handlePress : null,
          child: child,
        );
        break;
    }

    return button;
  }

  void _handlePress() {
    HapticService().mediumTap();
    onPressed();
  }
}

/// Carte interactive avec feedback haptique
class HapticCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const HapticCard({
    super.key,
    required this.onTap,
    required this.child,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      child: InkWell(
        onTap: () {
          HapticService().lightClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
