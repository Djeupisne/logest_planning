import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultantHomePage extends StatefulWidget {
  const ConsultantHomePage({super.key});

  @override
  State<ConsultantHomePage> createState() => _ConsultantHomePageState();
}

class _ConsultantHomePageState extends State<ConsultantHomePage> {
  int _selectedIndex = 0;

  final List<Mission> _missions = [
    Mission(id: 1, title: "Installation réseau", client: "Banque Sahélo-Saharienne", address: "Avenue Charles de Gaulle, N'Djamena", lat: 12.1348, lng: 15.0557, start: "09:00", end: "12:00", status: "en_route", contact: "M. Ibrahim", phone: "+235 66 12 34 56"),
    Mission(id: 2, title: "Formation utilisateurs", client: "Ministère des Finances", address: "Quartier Diguel, N'Djamena", lat: 12.1200, lng: 15.0500, start: "14:00", end: "17:00", status: "in_progress", contact: "Mme. Fatima", phone: "+235 66 23 45 67"),
    Mission(id: 3, title: "Maintenance serveur", client: "Université de N'Djamena", address: "Quartier Moursal, N'Djamena", lat: 12.1100, lng: 15.0400, start: "10:00", end: "13:00", status: "arrived", contact: "Pr. Ahmed", phone: "+235 66 34 56 78"),
    Mission(id: 4, title: "Consultation IT", client: "Société Tchadienne", address: "Quartier Chagoua, N'Djamena", lat: 12.1250, lng: 15.0650, start: "15:00", end: "18:00", status: "planned", contact: "M. Oumar", phone: "+235 66 45 67 89"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGEST Planning', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () => _showSnack('Aucune nouvelle notification')),
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

  Widget _buildMissionCard(Mission m) {
    final color = _statusColor(m.status);
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
                Text(m.client, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(m.title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel(m.status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.access_time, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${m.start} - ${m.end}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 12),
              Icon(Icons.location_on, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(m.address, style: TextStyle(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _actionBtn(Icons.directions, 'Itinéraire', () => _openMap(m.lat, m.lng), Colors.green),
              const SizedBox(width: 8),
              _actionBtn(Icons.report_problem, 'Incident', () => _showIncidentDialog(m), Colors.orange),
              const SizedBox(width: 8),
              if (m.status != 'completed')
                _actionBtn(Icons.check_circle, _nextLabel(m.status), () => _updateStatus(m), Colors.blue)
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
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
            point: LatLng(m.lat, m.lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showMissionDetail(m),
              child: Tooltip(
                message: '${m.client}\n${m.start} - ${m.end}',
                child: Icon(Icons.location_pin, color: _statusColor(m.status), size: 40),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
        const SizedBox(height: 16),
        const Text('Jean Dupont', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Consultant', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text('consultant@logest.com', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 32),
        ListTile(leading: const Icon(Icons.phone), title: const Text('+235 66 12 34 56')),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
          onTap: () => _showSnack('Déconnexion...'),
        ),
      ]),
    );
  }

  // ── DIALOGS ───────────────────────────────────────────────────────────────
  void _showMissionDetail(Mission m) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          Text(m.client, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(m.title, style: TextStyle(color: Colors.grey[600])),
          const Divider(height: 28),
          _infoRow(Icons.access_time, '${m.start} - ${m.end}'),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on, m.address),
          const SizedBox(height: 10),
          _infoRow(Icons.person, m.contact),
          const SizedBox(height: 10),
          _infoRow(Icons.phone, m.phone),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close), label: const Text('Fermer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); _openMap(m.lat, m.lng); },
              icon: const Icon(Icons.directions), label: const Text('Itinéraire'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  void _showIncidentDialog(Mission m) {
    String type = 'Retard';
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Signaler un incident'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Retard', 'Problème technique', 'Client absent', 'Autre']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(onPressed: () { Navigator.pop(context); _showSnack('Incident signalé'); }, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Mission m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rédiger un rapport'),
        content: TextField(decoration: const InputDecoration(labelText: 'Commentaires'), maxLines: 4),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _showSnack('Rapport envoyé'); }, child: const Text('Envoyer')),
        ],
      ),
    );
  }

  void _updateStatus(Mission m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mettre à jour le statut'),
        content: Text('Passer à "${_nextLabel(m.status)}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _showSnack('Statut mis à jour'); }, child: const Text('Confirmer')),
        ],
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  String _statusLabel(String s) => {'en_route': 'En route', 'arrived': 'Arrivé', 'in_progress': 'En intervention', 'planned': 'Planifié', 'completed': 'Terminé'}[s] ?? s;
  String _nextLabel(String s) => {'en_route': 'Arrivé', 'arrived': 'En intervention', 'in_progress': 'Terminé'}[s] ?? 'Planifié';
  Color _statusColor(String s) => {'en_route': Colors.orange, 'arrived': Colors.blue, 'in_progress': Colors.green, 'planned': Colors.grey, 'completed': const Color(0xFF0F9D58)}[s] ?? Colors.grey;
}

class Mission {
  final int id;
  final String title, client, address, start, end, status, contact, phone;
  final double lat, lng;

  Mission({required this.id, required this.title, required this.client,
    required this.address, required this.lat, required this.lng,
    required this.start, required this.end, required this.status,
    required this.contact, required this.phone});
}