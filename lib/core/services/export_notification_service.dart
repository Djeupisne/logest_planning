import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Service complet pour les exports CSV, PDF et le partage
class ExportService {
  /// Exporte les données de missions en CSV et sauvegarde le fichier
  Future<String?> exportMissionsToCSV(List<Map<String, dynamic>> missions) async {
    final buffer = StringBuffer();
    
    // En-têtes CSV
    buffer.writeln('ID,Titre,Client,Adresse,Date Début,Date Fin,Statut,Consultant ID,Compétence');
    
    // Données
    for (final mission in missions) {
      buffer.writeln(
        '${mission['id']},'
        '"${_escapeCsv(mission['title'])}",'
        '"${_escapeCsv(mission['clientName'])}",'
        '"${_escapeCsv(mission['address'])}",'
        '${_formatDate(mission['scheduledStart'])},'
        '${_formatDate(mission['scheduledEnd'])},'
        '${mission['status']},'
        '${mission['consultantId']},'
        '"${_escapeCsv(mission['competence'] ?? 'N/A')}"'
      );
    }
    
    final csvData = buffer.toString();
    
    try {
      // Sauvegarder le fichier
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/missions_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);
      
      // Partager le fichier
      await Share.shareXFiles([XFile(filePath)], subject: 'Export Missions LOGEST');
      
      return filePath;
    } catch (e) {
      debugPrint('Erreur export CSV: $e');
      return null;
    }
  }
  
  /// Exporte les rapports de temps en CSV
  Future<String?> exportTimeReportsToCSV(List<Map<String, dynamic>> reports) async {
    final buffer = StringBuffer();
    
    buffer.writeln('Mission ID,Consultant,Date,Heures Estimées,Heures Réelles,Statut,Client');
    
    for (final report in reports) {
      buffer.writeln(
        '${report['missionId']},'
        '"${_escapeCsv(report['consultantName'])}",'
        '${_formatDate(report['date'])},'
        '${report['estimatedHours']},'
        '${report['actualHours']},'
        '${report['status']},'
        '"${_escapeCsv(report['clientName'])}"'
      );
    }
    
    final csvData = buffer.toString();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/rapports_temps_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);
      
      await Share.shareXFiles([XFile(filePath)], subject: 'Rapports Temps LOGEST');
      
      return filePath;
    } catch (e) {
      debugPrint('Erreur export rapports: $e');
      return null;
    }
  }
  
  /// Génère un PDF complet de rapport de mission avec signature
  Future<void> generateMissionReportPDF(Map<String, dynamic> mission, {Uint8List? signatureImage}) async {
    final pdf = pw.Document();
    
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('LOGEST', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                      pw.Text('Société de Conseil', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RAPPORT DE MISSION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Réf: ${mission['id']}', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Informations mission
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INFORMATIONS GÉNÉRALES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                  pw.SizedBox(height: 10),
                  _buildRow('Titre:', mission['title']),
                  _buildRow('Client:', mission['clientName']),
                  _buildRow('Adresse:', mission['address']),
                  _buildRow('Contact:', mission['contactName'] ?? 'N/A'),
                  _buildRow('Téléphone:', mission['contactPhone'] ?? 'N/A'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 15),
            
            // Planning
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PLANIFICATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                  pw.SizedBox(height: 10),
                  _buildRow('Date:', dateFmt.format(mission['scheduledStart'] as DateTime)),
                  _buildRow('Début:', DateFormat('HH:mm').format(mission['scheduledStart'] as DateTime)),
                  _buildRow('Fin prévue:', DateFormat('HH:mm').format(mission['scheduledEnd'] as DateTime)),
                  _buildRow('Statut:', mission['status']),
                  _buildRow('Type:', mission['type'] ?? 'facturée'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 15),
            
            // Commentaires
            if (mission['comments'] != null && (mission['comments'] as String).isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('COMMENTAIRES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    pw.SizedBox(height: 8),
                    pw.Text(mission['comments'], style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
            ],
            
            // Signature
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SIGNATURE CLIENT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                  pw.SizedBox(height: 15),
                  if (signatureImage != null)
                    pw.Image(pw.MemoryImage(signatureImage), width: 200, height: 100)
                  else
                    pw.Container(
                      width: double.infinity,
                      height: 100,
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey, width: 1, style: pw.BorderStyle.solid)),
                      child: pw.Center(child: pw.Text('Signature non disponible', style: pw.TextStyle(color: PdfColors.grey))),
                    ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.Spacer(),
            
            // Pied de page
            pw.Footer(
              margin: const pw.EdgeInsets.only(top: 20),
              builder: (pw.Context context) => pw.Column(
                children: [
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('LOGEST - Rapport généré le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                      pw.Text('Page ${context.pageNumber}/${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    
    // Imprimer ou partager le PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
  
  /// Partage un fichier via le système natif
  Future<bool> shareFile(String filePath, {String subject = 'Fichier LOGEST', String text = ''}) async {
    try {
      await Share.shareXFiles([XFile(filePath)], subject: subject, text: text);
      return true;
    } catch (e) {
      debugPrint('Erreur partage: $e');
      return false;
    }
  }
  
  /// Ouvre un email pré-rempli
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<String>? attachments,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    } else {
      debugPrint('Impossible d\'ouvrir le client email');
      return false;
    }
  }
  
  // Helpers
  String _escapeCsv(String? value) {
    if (value == null) return '';
    return value.replaceAll('"', '""');
  }
  
  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return date.toString();
  }
  
  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
          children: [
            pw.TextSpan(text: label, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}

/// Service de notifications push et locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  bool _isInitialized = false;
  
  /// Initialise le service de notifications
  Future<void> init() async {
    if (_isInitialized) return;
    
    // TODO: Intégrer Firebase Cloud Messaging
    // await FirebaseMessaging.instance.requestPermission();
    // await FirebaseMessaging.instance.getToken();
    
    debugPrint('Service de notifications initialisé');
    _isInitialized = true;
  }
  
  /// Demande la permission pour les notifications push
  Future<bool> requestPermission() async {
    // TODO: Implémenter avec firebase_messaging
    debugPrint('Demande de permission pour les notifications');
    return true; // Simulé
  }
  
  /// Affiche une notification locale
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    // TODO: Utiliser flutter_local_notifications
    debugPrint('NOTIFICATION LOCALE: $title - $body');
    
    // Simulation avec un print - à remplacer par la vraie implémentation
    // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // await flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails('logest_channel', 'LOGEST', channelDescription: 'Notifications LOGEST'),
    //   ),
    //   payload: payload,
    // );
  }
  
  /// Programme un rappel pour une mission
  Future<void> scheduleMissionReminder({
    required int missionId,
    required String title,
    required DateTime scheduledTime,
  }) async {
    // TODO: Utiliser workmanager ou flutter_local_notifications
    debugPrint('Rappel programmé pour la mission $missionId à ${scheduledTime.toString()}');
    
    // Exemple avec flutter_local_notifications:
    // final scheduledDate = scheduledTime.subtract(const Duration(minutes: 30));
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   missionId,
    //   'Rappel Mission',
    //   title,
    //   scheduledDate,
    //   const NotificationDetails(...),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }
  
  /// Annule un rappel
  Future<void> cancelReminder(int reminderId) async {
    debugPrint('Rappel $reminderId annulé');
    // await flutterLocalNotificationsPlugin.cancel(reminderId);
  }
  
  /// Envoie une notification push (via backend)
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Appeler le backend qui utilisera FCM
    debugPrint('PUSH NOTIFICATION pour $userId: $title - $body');
    
    // Exemple d'appel API au backend:
    // await dio.post('/api/notifications/push', data: {
    //   'user_id': userId,
    //   'title': title,
    //   'body': body,
    //   'data': data,
    // });
  }
  
  /// S'abonne à un topic FCM
  Future<void> subscribeToTopic(String topic) async {
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Abonné au topic: $topic');
  }
  
  /// Se désabonne d'un topic FCM
  Future<void> unsubscribeFromTopic(String topic) async {
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint('Désabonné du topic: $topic');
  }
  
  /// Configure les handlers pour les notifications en background
  void setupBackgroundHandlers() {
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Handlers background configurés');
  }
}

/// Handler pour les notifications push en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Notification background: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}
