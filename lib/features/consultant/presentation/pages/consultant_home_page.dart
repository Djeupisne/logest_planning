// lib/features/consultant/presentation/pages/consultant_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ConsultantHomePage extends StatefulWidget {
  const ConsultantHomePage({super.key});

  @override
  State<ConsultantHomePage> createState() => _ConsultantHomePageState();
}

class _ConsultantHomePageState extends State<ConsultantHomePage> {
  int _selectedIndex = 0;
  File? _incidentImage;
  final ImagePicker _imagePicker = ImagePicker();
  final List<Map<String, dynamic>> _reportedIncidents = [];

  final List<Map<String, dynamic>> _missions = [
    {'id': 1, 'title': "Installation réseau", 'client': "Banque Sahélo-Saharienne", 'address': "Avenue Charles de Gaulle, N'Djamena", 'lat': 12.1348, 'lng': 15.0557, 'start': "09:00", 'end': "12:00", 'status': "en_route", 'contact': "M. Ibrahim", 'phone': "+235 66 12 34 56"},
    {'id': 2, 'title': "Formation utilisateurs", 'client': "Ministère des Finances", 'address': "Quartier Diguel, N'Djamena", 'lat': 12.1200, 'lng': 15.0500, 'start': "14:00", 'end': "17:00", 'status': "in_progress", 'contact': "Mme. Fatima", 'phone': "+235 66 23 45 67"},
    {'id': 3, 'title': "Maintenance serveur", 'client': "Université de N'Djamena", 'address': "Quartier Moursal, N'Djamena", 'lat': 12.1100, 'lng': 15.0400, 'start': "10:00", 'end': "13:00", 'status': "arrived", 'contact': "Pr. Ahmed", 'phone': "+235 66 34 56 78"},
    {'id': 4, 'title': "Consultation IT", 'client': "Société Tchadienne", 'address': "Quartier Chagoua, N'Djamena", 'lat': 12.1250, 'lng': 15.0650, 'start': "15:00", 'end': "18:00", 'status': "planned", 'contact': "M. Oumar", 'phone': "+235 66 45 67 89"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _selectedIndex != 0 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedIndex = 0))
            : null,
        title: const Text('LOGEST Planning', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () => _showSnack('Aucune nouvelle notification'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildListTab(),
          _buildMapTab(),
          _buildPlanningTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Liste'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => _showSnack('Synchronisation effectuée'),
        child: const Icon(Icons.sync),
      )
          : null,
    );
  }

  // ── LISTE ─────────────────────────────────────────────────────────────────
  Widget _buildListTab() {
    return RefreshIndicator(
      onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _missions.length,
        itemBuilder: (_, i) => _buildMissionCard(_missions[i]),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> m) {
    final color = _statusColor(m['status'] as String);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showMissionDetail(m),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.work, color: color)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['client'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(m['title'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel(m['status'] as String), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.access_time, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${m['start']} - ${m['end']}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 12),
              Icon(Icons.location_on, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(m['address'] as String, style: TextStyle(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _actionBtn(Icons.directions, 'Itinéraire', () => _openMap(m['lat'] as double, m['lng'] as double), Colors.green),
              const SizedBox(width: 8),
              _actionBtn(Icons.report_problem, 'Incident', () => _showIncidentDialog(m), Colors.orange),
              const SizedBox(width: 8),
              if (m['status'] as String != 'completed')
                _actionBtn(Icons.check_circle, _nextLabel(m['status'] as String), () => _updateStatus(m), Colors.blue)
              else
                _actionBtn(Icons.edit_note, 'Rapport', () => _showReportDialog(m), Colors.purple),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, Color color) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          // Feedback haptique et visuel avant l'action
          onTap();
        },
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
        ),
      ),
    );
  }

  // ── CARTE (OpenStreetMap via flutter_map) ─────────────────────────────────
  Widget _buildMapTab() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(12.1348, 15.0557),
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.logest.planning',
        ),
        MarkerLayer(
          markers: _missions.map((m) => Marker(
            point: LatLng(m['lat'] as double, m['lng'] as double),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showMissionDetail(m),
              child: Tooltip(
                message: '${m['client']}\n${m['start']} - ${m['end']}',
                child: Icon(Icons.location_pin, color: _statusColor(m['status'] as String), size: 40),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ── PLANNING ──────────────────────────────────────────────────────────────
  Widget _buildPlanningTab() {
    final days = [
      {'label': 'Lundi', 'count': 2, 'done': true},
      {'label': 'Mardi', 'count': 1, 'done': true},
      {'label': 'Mercredi', 'count': 0, 'done': false},
      {'label': 'Jeudi', 'count': 1, 'done': false},
      {'label': 'Vendredi', 'count': 0, 'done': false},
      {'label': 'Samedi', 'count': 0, 'done': false},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final d = days[i];
        final count = d['count'] as int;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text((d['label'] as String)[0])),
            title: Text(d['label'] as String),
            subtitle: Text(count == 0 ? 'Aucune mission' : '$count mission${count > 1 ? 's' : ''}'),
            trailing: Icon(
              count > 0 ? Icons.check_circle : Icons.event_busy,
              color: count > 0 ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  // ── PROFIL ────────────────────────────────────────────────────────────────
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // En-tête du profil avec dégradé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jean Dupont',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Consultant Senior',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem('42', 'Missions'),
                    Container(width: 1, height: 30, color: Colors.white30),
                    _buildStatItem('98%', 'Ponctualité'),
                    Container(width: 1, height: 30, color: Colors.white30),
                    _buildStatItem('4.8/5', 'Satisfaction'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Section Informations de contact
          _buildSectionTitle('Informations de contact'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildInfoTile(Icons.email, 'consultant@logest.com', 'Email'),
                const Divider(height: 1, indent: 60),
                _buildInfoTile(Icons.phone, '+235 66 12 34 56', 'Téléphone'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Section Incidents
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bug_report, color: Colors.orange[700], size: 24),
              ),
              title: Text(
                'Incidents signalés',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                '${_reportedIncidents.length} incident${_reportedIncidents.length > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chevron_right, color: Colors.grey[700]),
              ),
              onTap: () => _showIncidentsList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Bouton de déconnexion
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.red[600]!, Colors.red[400]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, size: 24),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[700], size: 22),
      ),
      title: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMissionDetail(Map<String, dynamic> m) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          Text(m['client'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(m['title'], style: TextStyle(color: Colors.grey[600])),
          const Divider(height: 28),
          _infoRow(Icons.access_time, '${m['start']} - ${m['end']}'),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on, m['address']),
          const SizedBox(height: 10),
          _infoRow(Icons.person, m['contact']),
          const SizedBox(height: 10),
          _infoRow(Icons.phone, m['phone']),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close), label: const Text('Fermer'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); _openMap(m['lat'], m['lng']); },
              icon: const Icon(Icons.directions), label: const Text('Itinéraire'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 18, color: Colors.grey[600]),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ]);
  }

  void _showIncidentDialog(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.report_problem, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Text('Signaler un incident', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mission: ${m['client']} - ${m['title']}',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description de l\'incident',
                    hintText: 'Décrivez le problème rencontré...',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Text('Photo (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _incidentImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _incidentImage!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 4),
                                  Text('Aucune photo', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final picked = await _imagePicker.pickImage(source: ImageSource.camera);
                              if (picked != null) {
                                setDialogState(() => _incidentImage = File(picked.path));
                              }
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.blue[700]),
                            tooltip: 'Prendre une photo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setDialogState(() => _incidentImage = File(picked.path));
                              }
                            },
                            icon: Icon(Icons.photo_library, color: Colors.green[700]),
                            tooltip: 'Choisir depuis la galerie',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_incidentImage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setDialogState(() => _incidentImage = null);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Supprimer', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _incidentImage = null;
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final description = 'Incident sur ${m['client']} - ${m['title']}';
                _reportedIncidents.add({
                  'missionId': m['id'],
                  'client': m['client'],
                  'title': m['title'],
                  'description': description,
                  'date': DateTime.now(),
                  'hasPhoto': _incidentImage != null,
                });
                Navigator.pop(context);
                _incidentImage = null;
                setState(() {});
                _showSnack('Incident signalé avec succès');
              },
              icon: const Icon(Icons.send),
              label: const Text('Envoyer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rapport de mission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Commentaires', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 16),
            const Text('Signature du client:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('Zone de signature (à implémenter)', style: TextStyle(color: Colors.grey[400]))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Rapport enregistré avec succès');
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(Map<String, dynamic> m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mettre à jour le statut'),
        content: Text('Passer à "${_nextLabel(m['status'])}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _showSnack('Statut mis à jour'); }, child: const Text('Confirmer')),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    // URL optimisée pour Android avec mode de navigation
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Ouvre dans l'application Google Maps
        );
      } else {
        _showSnack('Impossible d\'ouvrir la carte', isError: true);
      }
    } catch (e) {
      _showSnack('Erreur lors de l\'ouverture de la carte: ${e.toString()}', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(msg, style: const TextStyle(fontSize: 14))),
            ],
          ),
          backgroundColor: isError ? Colors.red[700] : const Color(0xFF0F9D58),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

  void _showIncidentsList() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Incidents signalés (${_reportedIncidents.length})',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800]),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _reportedIncidents.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun incident signalé',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tous les incidents seront affichés ici',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reportedIncidents.length,
                  itemBuilder: (_, i) {
                    final inc = _reportedIncidents[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Icon(Icons.report_problem, color: Colors.orange[700]),
                        ),
                        title: Text(
                          '${inc['client']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              inc['title'],
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(inc['date'] as DateTime),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                ),
                                if (inc['hasPhoto'] == true) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.photo, size: 10, color: Colors.blue[700]),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Photo',
                                          style: TextStyle(color: Colors.blue[700], fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Fermer', style: TextStyle(color: Colors.grey[700])),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(String s) => {'en_route': 'En route', 'arrived': 'Arrivé', 'in_progress': 'En intervention', 'planned': 'Planifié', 'completed': 'Terminé'}[s] ?? s;
  String _nextLabel(String s) => {'en_route': 'Arrivé', 'arrived': 'En intervention', 'in_progress': 'Terminé'}[s] ?? 'Planifié';
  Color _statusColor(String s) => {'en_route': Colors.orange, 'arrived': Colors.blue, 'in_progress': Colors.green, 'planned': Colors.grey, 'completed': const Color(0xFF0F9D58)}[s] ?? Colors.grey;
}