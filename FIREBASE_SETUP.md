# 📡 Configuration Firebase - LOGEST Planning

## 1. Créer un projet Firebase

1. Rendez-vous sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Nommez-le `logest-planning`
4. Activez Google Analytics (optionnel)
5. Créez le projet

---

## 2. Activer Cloud Messaging (FCM)

1. Dans la console Firebase, allez dans **Engagement** → **Cloud Messaging**
2. Cliquez sur "Commencer" pour activer FCM
3. Notez vos identifiants de serveur

---

## 3. Configurer l'application Flutter

### 3.1 Ajouter les fichiers de configuration

#### Pour Android:
1. Téléchargez `google-services.json` depuis Firebase Console
2. Placez-le dans `android/app/google-services.json`

#### Pour iOS:
1. Téléchargez `GoogleService-Info.plist` depuis Firebase Console
2. Placez-le dans `ios/Runner/GoogleService-Info.plist`

### 3.2 Mettre à jour pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
```

### 3.3 Initialiser Firebase dans main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Configurer les notifications push
  await setupPushNotifications();
  
  runApp(MyApp());
}

Future<void> setupPushNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Demander la permission
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permission accordée pour les notifications');
    
    // Récupérer le token FCM
    String? token = await messaging.getToken();
    print('Token FCM: $token');
    
    // Envoyer le token au backend pour stockage
    // await apiService.updateFcmToken(token);
  }
  
  // Gérer les notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Gérer les notifications quand l'app est au premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Notification reçue: ${message.notification?.title}');
    // Afficher une notification locale ou mettre à jour l'UI
  });
  
  // Gérer le clic sur une notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification cliquée!');
    // Naviguer vers l'écran approprié
    if (message.data['type'] == 'mission') {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetails(message.data['id'])));
    }
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Notification en arrière-plan: ${message.messageId}');
}
```

---

## 4. Backend - Envoi de notifications

### 4.1 Installer Firebase Admin SDK (Node.js)

```bash
npm install firebase-admin
```

### 4.2 Configuration du backend

```javascript
// backend/api/src/firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const messaging = admin.messaging();

module.exports = { admin, messaging };
```

### 4.3 Fonction d'envoi de notification

```javascript
// backend/api/src/services/notificationService.js
const { messaging } = require('../firebase');

async function sendPushNotification(deviceToken, title, body, data = {}) {
  try {
    const message = {
      notification: {
        title,
        body,
      },
      data,
      token: deviceToken,
      android: {
        priority: 'high',
        notification: {
          channelId: 'missions',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    const response = await messaging.send(message);
    console.log('Notification envoyée avec succès:', response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Erreur envoi notification:', error);
    return { success: false, error: error.message };
  }
}

async function sendTopicNotification(topic, title, body, data = {}) {
  try {
    const message = {
      notification: { title, body },
      data,
      topic,
    };

    const response = await messaging.send(message);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Erreur envoi topic:', error);
    return { success: false, error: error.message };
  }
}

module.exports = { sendPushNotification, sendTopicNotification };
```

### 4.4 Intégrer dans les endpoints API

```javascript
// Exemple: envoyer notification lors de l'assignation d'une mission
const { sendPushNotification } = require('./services/notificationService');

app.post('/api/missions', authenticateToken, authorizeRole('planner', 'director'), async (req, res) => {
  // ... création de la mission ...
  
  const result = await pool.query(/* INSERT mission */);
  const mission = result.rows[0];
  
  // Envoyer notification au consultant
  if (mission.consultant_id) {
    const consultantToken = await getConsultantFcmToken(mission.consultant_id);
    if (consultantToken) {
      await sendPushNotification(
        consultantToken,
        'Nouvelle mission assignée',
        `Mission: ${mission.title}`,
        { type: 'mission', missionId: mission.id, action: 'new' }
      );
    }
  }
  
  res.status(201).json({ success: true, data: mission });
});
```

---

## 5. Types de notifications

| Événement | Titre | Corps | Données |
|-----------|-------|-------|---------|
| Nouvelle mission | "Nouvelle mission" | "{titre} à {lieu}" | `{type: 'mission', id: ..., action: 'new'}` |
| Modification planning | "Planning modifié" | "Votre planning a été mis à jour" | `{type: 'planning', action: 'update'}` |
| Rappel mission | "Rappel" | "Mission dans 30 min: {titre}" | `{type: 'reminder', missionId: ...}` |
| Incident | "Incident signalé" | "{consultant} a signalé un problème" | `{type: 'incident', id: ...}` |
| Synchronisation | "Données synchronisées" | "Vos données ont été mises à jour" | `{type: 'sync'}` |

---

## 6. Tests des notifications

### Via Firebase Console:
1. Allez dans **Engagement** → **Cloud Messaging**
2. Cliquez sur "Nouvelle campagne"
3. Choisissez "Notification"
4. Testez avec votre appareil

### Via cURL:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "DEVICE_FCM_TOKEN",
      "notification": {
        "title": "Test",
        "body": "Ceci est un test"
      },
      "data": {
        "type": "test"
      }
    }
  }'
```

---

## 7. Bonnes pratiques

✅ **À faire:**
- Stocker les tokens FCM dans la table `users` ou `consultants`
- Mettre à jour le token à chaque connexion
- Gérer les tokens invalides (supprimer après erreur 404)
- Personnaliser les notifications par rôle
- Utiliser les canaux Android pour catégoriser

❌ **À éviter:**
- Envoyer trop de notifications (risque de désactivation)
- Notifications hors heures de travail (sauf urgence)
- Oublier de gérer les erreurs d'envoi
- Ne pas tester sur vrais appareils

---

## 8. Prochaines étapes

1. ✅ Créer projet Firebase
2. ✅ Télécharger fichiers de config
3. ✅ Ajouter dépendances Flutter
4. ✅ Implémenter `setupPushNotifications()` dans `lib/main.dart`
5. ✅ Configurer backend avec Firebase Admin SDK
6. ✅ Tester envoi depuis console Firebase
7. ✅ Intégrer dans les endpoints API
8. ✅ Déployer en production

---

## Ressources

- [Documentation Firebase Flutter](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
