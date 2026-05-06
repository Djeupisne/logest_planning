# 📱 LOGEST Planning - Guide de Déploiement

## Vue d'ensemble

Application de planification des activités quotidiennes des consultants de l'entreprise LOGEST au Tchad.

### Objectifs
- Réduire de 50% le temps de planification quotidienne
- Garantir que tous les consultants consultent leur planning avant 9 heures
- Réduire de 70% les appels de coordination
- Assurer une saisie complète des temps de travail

---

## ✅ Fonctionnalités Implémentées pour le Déploiement

### 1. Permissions Mobile (Android & iOS)

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Géolocalisation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Caméra et stockage -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous utilisons votre position pour afficher les missions sur la carte et fournir des itinéraires GPS pendant vos heures de travail.</string>

<key>NSCameraUsageDescription</key>
<string>Nous utilisons la caméra pour prendre des photos des rapports de mission et des incidents.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Nous accédons à votre galerie pour sélectionner des photos pour les rapports de mission.</string>
```

---

### 2. Services Core Implémentés

#### a. Service de Sécurité et Synchronisation (`lib/core/services/security_sync_service.dart`)

**EncryptionService** :
- Chiffrement des données sensibles via `flutter_secure_storage`
- Stockage sécurisé des tokens et informations confidentielles

**SyncService** :
- Gestion de la file d'attente des opérations hors-ligne
- Synchronisation automatique lors du retour en ligne
- Types d'opérations supportées :
  - `mission_update` : Mise à jour du statut des missions
  - `incident_report` : Signalement d'incidents
  - `mission_report` : Rapports de mission avec signature

**OfflineQueue** :
- File d'attente pour les opérations en mode déconnecté
- Persistance locale avec Hive

#### b. Service de Géolocalisation (`lib/core/services/location_service.dart`)

Fonctionnalités clés :
- **Respect de la vie privée** : Suivi GPS uniquement pendant les heures de travail
- **Gestion des permissions** : Demande explicite de consentement
- **Suivi en temps réel** : Stream de positions pour le planificateur
- **Calcul de distance** : Vérification de proximité aux sites clients
- **Configuration des heures de travail** : 
  ```dart
  LocationService().setWorkHours(
    DateTime(2024, 1, 15, 8, 0),  // 8h00
    DateTime(2024, 1, 15, 18, 0), // 18h00
  );
  ```

#### c. Service de Connectivité (`lib/core/services/connectivity_service.dart`)

Fonctionnalités :
- Détection automatique online/offline
- Synchronisation automatique au retour en ligne
- Écouteurs de changement de connectivité
- Force sync manuelle

Utilisation :
```dart
final connectivityService = ConnectivityService();
await connectivityService.init();

// Vérifier l'état
if (connectivityService.isOnline) {
  // Opérations en ligne
} else {
  // Mode hors-ligne activé
}
```

#### d. Service d'Export et Notifications (`lib/core/services/export_notification_service.dart`)

**ExportService** :
- Export CSV des missions
- Export CSV des rapports de temps
- Génération de PDF (rapports de mission)
- Partage de fichiers
- Envoi d'emails

**NotificationService** :
- Notifications locales
- Rappels de missions programmés
- Support pour Firebase Cloud Messaging (à configurer)

---

### 3. Module Consultant (Mobile)

**Fonctionnalités implémentées** :
- ✅ Consultation agenda journalier avec détails (horaires, adresses, contacts)
- ✅ Mise à jour du statut en temps réel : "en route", "arrivé", "en intervention", "terminé", "problème"
- ✅ Itinéraire GPS en un clic (Google Maps / OpenStreetMap)
- ✅ Signalement de retards/incidents
- ✅ Compte-rendu avec texte et photo (prêt pour implémentation)
- ✅ Signature client (interface prête)
- ✅ Consultation planning hebdomadaire (J+1 à J+5)
- ✅ Mode déconnecté avec synchronisation automatique

**Pages** :
- `ConsultantHomePage` : Liste des missions, carte, planning, profil
- Navigation par tabs : Liste | Carte | Planning | Profil

---

### 4. Module Planificateur (Web/Mobile)

**Fonctionnalités implémentées** :
- ✅ Création de missions avec toutes les informations
- ✅ Affectation aux consultants
- ✅ Visualisation des consultants sur carte (avec consentement)
- ✅ Planning global hebdomadaire
- ✅ Gestion des congés et disponibilités
- ✅ Indicateurs de suivi (retards, disponibilité)
- ✅ Gestion par compétences

**Pages** :
- `PlannerDashboard` : Planning hebdo + liste consultants
- `CreateMissionDialog` : Formulaire de création
- `ConsultantMapDialog` : Carte de localisation

**Code couleur planning** :
- 🟢 Vert : Missions facturées
- ⚫ Gris : Inter-contrat
- 🔵 Bleu : Congés
- 🟡 Jaune : Formations

---

### 5. Module Direction (Reporting)

**Fonctionnalités implémentées** :
- ✅ Taux d'utilisation des consultants
- ✅ Comparaison temps déclarés vs estimés
- ✅ Export CSV des données
- ✅ Impression des rapports
- ✅ Tableaux de bord graphiques (fl_chart)

**KPIs affichés** :
- Taux d'utilisation (%)
- Missions terminées
- Retards signalés
- Consultants actifs

**Graphiques** :
- Courbe d'utilisation mensuelle
- Comparatif estimé vs réel
- Synthèse annuelle

---

### 6. Authentification et Sécurité

**Implémenté** :
- ✅ Login par email/mot de passe
- ✅ Rôles : consultant, planner, director
- ✅ Session persistante avec Hive
- ✅ Comptes de test pré-configurés :
  - Consultant : `consultant@logest.com` / `password`
  - Planificateur : `planner@logest.com` / `password`
  - Direction : `direction@logest.com` / `password`

**À renforcer pour production** :
- [ ] Hashage des mots de passe (bcrypt)
- [ ] Tokens JWT avec expiration
- [ ] HTTPS obligatoire
- [ ] 2FA optionnel

---

### 7. Base de Données Locale (Hive)

**Boxes configurées** :
- `users` : Utilisateurs authentifiés
- `missions` : Missions (avec modèle adaptateur)
- `incidents` : Incidents signalés
- `pending_sync` : Opérations en attente de synchronisation

**Seed data** :
- 4 utilisateurs de test
- 3 missions exemple

---

## 📋 Checklist de Déploiement

### Avant Déploiement

#### Configuration Backend (À FAIRE)
- [ ] Mettre en place API REST (Node.js/Django/Spring)
- [ ] Configurer base de données PostgreSQL/MySQL
- [ ] Implémenter endpoints :
  - `POST /api/auth/login`
  - `GET /api/missions`
  - `PUT /api/missions/:id/status`
  - `POST /api/incidents`
  - `GET /api/consultants`
  - `GET /api/reports`

#### Firebase (Pour Notifications Push)
- [ ] Créer projet Firebase
- [ ] Ajouter fichier `google-services.json` (Android)
- [ ] Ajouter fichier `GoogleService-Info.plist` (iOS)
- [ ] Installer `firebase_messaging` dans `pubspec.yaml`
- [ ] Configurer VAPID keys pour le web

#### Google Maps API (Optionnel)
- [ ] Obtenir API Key Google Maps
- [ ] Activer :
  - Maps SDK for Android
  - Maps SDK for iOS
  - Directions API
- [ ] Ajouter clé dans `AndroidManifest.xml` et `Info.plist`

### Build Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Signer l'application
# Créer keystore :
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configurer dans android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

### Build iOS

```bash
# Build pour App Store
flutter build ipa --release

# Ouvrir dans Xcode pour signature et distribution
open ios/Runner.xcworkspace
```

### Build Web

```bash
flutter build web --release

# Déployer sur :
# - Firebase Hosting
# - Vercel
# - Netlify
# - Serveur nginx/Apache
```

---

## 🔧 Configuration Spécifique Tchad

### Optimisations Réseau
- Mode offline prioritaire
- Synchronisation légère (< 5 secondes)
- Compression des images
- Cache agressif des données

### Cartographie
- OpenStreetMap par défaut (gratuit)
- Support Google Maps en option
- Adresses textuelles précises (repères non standardisés)

### Langues
- Français (actuel)
- Arabe tchadien (à ajouter)
- Sara (à ajouter)

---

## 📊 Métriques de Performance Cibles

| Métrique | Cible | Mesure |
|----------|-------|--------|
| Temps affichage | < 2s | Time to Interactive |
| Sync données | < 5s | Offline → Online |
| Batterie | < 5%/heure | Avec GPS actif |
| Taille APK | < 50 Mo | Download initial |

---

## 🐛 Tests Requis

### Tests Unitaires
```bash
flutter test
```

### Tests d'Intégration
- [ ] Flux complet consultant (login → mission → rapport)
- [ ] Flux planificateur (création → affectation → suivi)
- [ ] Mode hors-ligne (création → sync)
- [ ] Permissions (refus → acceptation)

### Tests Utilisateurs
- [ ] Consultant terrain (N'Djamena)
- [ ] Planificateur (bureau)
- [ ] Directeur (reporting)

---

## 📞 Support et Maintenance

### Logs et Monitoring
- Intégrer Sentry ou Firebase Crashlytics
- Logs structurés pour débogage
- Analytics d'usage (anonymisés)

### Mises à Jour
- Versioning sémantique (MAJOR.MINOR.PATCH)
- Notes de version détaillées
- Migration de données si besoin

---

## 📄 Livrables

- ✅ Application mobile Android (APK/AAB)
- ✅ Application mobile iOS (IPA)
- ✅ Interface web responsive
- ✅ Documentation utilisateur (FR)
- ✅ Documentation technique
- ✅ Code source commenté
- ⏳ Backend API (à développer)
- ⏳ Base de données production (à configurer)

---

## 🎯 Prochaines Étapes

1. **Backend API** : Développer les endpoints REST
2. **Firebase** : Configurer notifications push
3. **Tests** : Campagne de tests utilisateurs au Tchad
4. **Formation** : Sessions de formation pour consultants et planificateurs
5. **Déploiement pilote** : 5-10 consultants pour validation
6. **Généralisation** : Déploiement à toute l'équipe

---

**Contact** : Équipe de développement  
**Version** : 1.0.0  
**Date** : Janvier 2024
