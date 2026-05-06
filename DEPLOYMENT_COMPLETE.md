# 🚀 Guide de Déploiement Complet - LOGEST Planning

## Table des Matières

1. [Prérequis](#prérequis)
2. [Backend API](#backend-api)
3. [Base de données](#base-de-données)
4. [Application Flutter](#application-flutter)
5. [Firebase](#firebase)
6. [Sécurité](#sécurité)
7. [Tests utilisateurs](#tests-utilisateurs)
8. [Maintenance](#maintenance)

---

## Prérequis

### Matériel
- Serveur VPS (minimum 2GB RAM, 2 CPU cores)
- Nom de domaine pour HTTPS
- Compte Google Cloud (pour Firebase)

### Logiciels
- Docker & Docker Compose
- Node.js 18+
- PostgreSQL 15+ avec PostGIS
- Flutter SDK 3.x
- Git

---

## Backend API

### Option 1: Déploiement avec Docker (Recommandé)

```bash
cd /workspace/backend

# Copier le fichier d'environnement
cp api/.env.example api/.env

# Éditer .env avec vos valeurs
nano api/.env

# Démarrer tous les services
docker-compose up -d

# Vérifier les logs
docker-compose logs -f api
```

### Option 2: Déploiement manuel

```bash
cd /workspace/backend/api

# Installer les dépendances
npm install

# Copier et configurer .env
cp .env.example .env
nano .env

# Lancer les migrations
psql -U postgres -d logest_planning -f ../scripts/migrate.sql

# Démarrer le serveur
npm start

# Ou en production avec PM2
npm install -g pm2
pm2 start src/server.js --name logest-api
pm2 save
pm2 startup
```

---

## Base de données

### Installation PostgreSQL + PostGIS

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib postgis postgresql-15-postgis-3

# Configurer PostgreSQL
sudo -u postgres psql

CREATE DATABASE logest_planning;
CREATE EXTENSION postgis;
\q

# Importer le schéma
psql -U postgres -d logest_planning -f /workspace/backend/scripts/migrate.sql
```

### Sauvegarde automatique

```bash
# Script de backup (/usr/local/bin/backup-logest.sh)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U postgres logest_planning > /backups/logest_$DATE.sql
find /backups -name "logest_*.sql" -mtime +7 -delete
```

```bash
# Cron job (éditer avec crontab -e)
0 2 * * * /usr/local/bin/backup-logest.sh
```

---

## Application Flutter

### Configuration

1. **Mett à jour l'URL de l'API** dans `lib/core/services/api_service.dart`:

```dart
class ApiService {
  // static const String baseUrl = 'http://localhost:3000/api'; // Dev
  static const String baseUrl = 'https://api.logest-planning.td/api'; // Production
  // ...
}
```

2. **Ajouter les fichiers Firebase**:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

3. **Configurer les permissions**:
   - Android: `AndroidManifest.xml` (déjà fait)
   - iOS: `Info.plist` (déjà fait)

### Build Android

```bash
cd /workspace

# Build APK
flutter build apk --release --split-per-abi

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Les fichiers seront dans:
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# - build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
cd /workspace

# Build IPA
flutter build ipa --release

# Ouvrir dans Xcode pour distribution
open ios/Runner.xcworkspace
```

### Build Web

```bash
cd /workspace

flutter build web --release

# Déployer sur un serveur web (Nginx, Apache, etc.)
# Les fichiers sont dans build/web/
```

---

## Firebase

Suivez le guide détaillé dans `FIREBASE_SETUP.md`:

1. Créer un projet Firebase
2. Activer Cloud Messaging
3. Télécharger les fichiers de configuration
4. Ajouter les dépendances Flutter
5. Configurer le backend avec Firebase Admin SDK

---

## Sécurité

### 1. HTTPS Obligatoire

```bash
# Avec Let's Encrypt (gratuit)
sudo apt install certbot python3-certbot-nginx

sudo certbot --nginx -d api.logest-planning.td

# Renouvellement automatique
sudo certbot renew --dry-run
```

### 2. Variables d'environnement sécurisées

```bash
# Générer un JWT_SECRET fort
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Utiliser .env jamais commité dans Git
echo ".env" >> .gitignore
```

### 3. Firewall

```bash
# Configurer UFW (Ubuntu)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # API (si pas derrière Nginx)
sudo ufw enable
```

### 4. Mises à jour de sécurité

```bash
# Mettre à jour régulièrement
sudo apt update && sudo apt upgrade -y

# Mettre à jour les dépendances npm
cd /workspace/backend/api
npm audit fix
npm update
```

---

## Tests Utilisateurs

### Phase 1: Tests internes (1 semaine)

**Participants:** 3-5 personnes de l'équipe

**Objectifs:**
- Valider toutes les fonctionnalités
- Identifier les bugs critiques
- Tester le mode offline

**Scénarios à tester:**
1. Connexion/déconnexion
2. Consultation planning
3. Mise à jour statut mission
4. Création rapport avec photo
5. Synchronisation offline/online
6. Réception notifications push

### Phase 2: Pilote terrain (2-3 semaines)

**Participants:** 5-10 consultants réels au Tchad

**Préparation:**
- Former les consultants (1h/session)
- Distribuer guide utilisateur
- Configurer appareils (Android minimum 8.0)
- Créer comptes test

**Suivi:**
- Réunion hebdomadaire de feedback
- Collecte des incidents
- Ajustements rapides

**Indicateurs de succès:**
- ✅ 90% des consultants consultent leur planning avant 9h
- ✅ Réduction de 50% des appels de coordination
- ✅ 80% des temps saisis via l'app
- ✅ Moins de 5% d'erreurs de synchronisation

### Phase 3: Déploiement général

Après validation du pilote:
- Déployer à tous les consultants
- Former les planificateurs et la direction
- Mettre en place support technique

---

## Maintenance

### Monitoring

```bash
# Installer PM2 pour monitoring
pm2 monit

# Logs en temps réel
pm2 logs logest-api

# Métriques
pm2 show logest-api
```

### Alertes

Configurer des alertes pour:
- ⚠️ CPU > 80% pendant 5 min
- ⚠️ RAM > 90%
- ⚠️ Espace disque < 10%
- ⚠️ API down (> 5 erreurs 5xx)

### Mises à jour

```bash
# Procédure de déploiement
cd /workspace

# 1. Récupérer les changements
git pull origin main

# 2. Installer dépendances
flutter pub get
cd backend/api && npm install

# 3. Redémarrer services
docker-compose restart
# ou
pm2 restart logest-api

# 4. Vérifier les logs
docker-compose logs -f
# ou
pm2 logs
```

### Support

Créer un canal de support:
- Email: support@logest-planning.td
- Téléphone: +235 XX XX XX XX
- WhatsApp groupe pour consultants

---

## Checklist de Déploiement

### Backend
- [ ] PostgreSQL installé avec PostGIS
- [ ] Schéma de base de données créé
- [ ] Backend API déployé
- [ ] HTTPS configuré
- [ ] Variables d'environnement sécurisées
- [ ] Backups automatiques activés
- [ ] Monitoring en place

### Mobile
- [ ] URL API mise à jour en production
- [ ] Fichiers Firebase ajoutés
- [ ] Permissions configurées
- [ ] APK/IPA générés
- [ ] Tests sur appareils réels

### Firebase
- [ ] Projet Firebase créé
- [ ] Cloud Messaging activé
- [ ] Notifications testées
- [ ] Backend intégré avec FCM

### Tests
- [ ] Tests internes complétés
- [ ] Pilote terrain validé
- [ ] Documentation utilisateur rédigée
- [ ] Formation des utilisateurs faite

### Sécurité
- [ ] Mots de passe hashés (bcrypt)
- [ ] JWT configuré avec expiration
- [ ] HTTPS obligatoire
- [ ] Rate limiting activé
- [ ] Firewall configuré

---

## Contacts Utiles

- **Développeur Lead:** [Votre email]
- **Support Technique:** support@logest-planning.td
- **Urgence Production:** +235 XX XX XX XX

---

## Ressources

- [Documentation API](./backend/README.md)
- [Guide Firebase](./FIREBASE_SETUP.md)
- [Schéma Base de Données](./backend/scripts/migrate.sql)
- [Code Source Flutter](./lib/)

---

**Version:** 1.0.0  
**Dernière mise à jour:** $(date +%Y-%m-%d)  
**Statut:** Prêt pour déploiement pilote ✅
