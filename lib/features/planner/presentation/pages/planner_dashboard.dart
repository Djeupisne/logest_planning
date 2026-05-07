// lib/features/planner/presentation/pages/planner_dashboard.dart
import 'package:flutter/material.dart';
import 'create_mission_dialog.dart';
import 'consultant_map_dialog.dart';
import 'mission_week_view.dart';
import '../widgets/skill_filter_widget.dart';
import '../../../core/services/export_notification_service.dart';

class PlannerDashboard extends StatefulWidget {
  const PlannerDashboard({super.key});

  @override
  State<PlannerDashboard> createState() => _PlannerDashboardState();
}

class _PlannerDashboardState extends State<PlannerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _filteredConsultants = [];

  final List<Map<String, dynamic>> _consultants = [
    {'id': 1, 'name': 'Jean Dupont', 'specialty': 'Réseau', 'status': 'disponible', 'color': Colors.green, 'missions': 3, 'lat': 12.1348, 'lng': 15.0557},
    {'id': 2, 'name': "Marie N'Djamena", 'specialty': 'Développement', 'status': 'en_mission', 'color': Colors.orange, 'missions': 2, 'lat': 12.1200, 'lng': 15.0500},
    {'id': 3, 'name': 'Ali Mahamat', 'specialty': 'Maintenance', 'status': 'disponible', 'color': Colors.blue, 'missions': 1, 'lat': 12.1100, 'lng': 15.0400},
    {'id': 4, 'name': 'Fatima Hassan', 'specialty': 'Formation', 'status': 'congé', 'color': Colors.grey, 'missions': 0, 'lat': 12.1250, 'lng': 15.0650},
    {'id': 5, 'name': 'Oumar Abakar', 'specialty': 'Consulting', 'status': 'disponible', 'color': Colors.purple, 'missions': 2, 'lat': 12.1300, 'lng': 15.0600},
  ];

  final List<Map<String, dynamic>> _missions = [
    {'title': 'Installation réseau', 'client': 'Banque Sahélo-Saharienne', 'consultantId': 1, 'date': '2024-05-06', 'time': '09:00-12:00', 'type': 'facturée', 'color': Colors.green},
    {'title': 'Formation Excel', 'client': 'Ministère Finances', 'consultantId': 2, 'date': '2024-05-06', 'time': '14:00-17:00', 'type': 'formation', 'color': Colors.yellow},
    {'title': 'Maintenance serveur', 'client': 'Université', 'consultantId': 3, 'date': '2024-05-07', 'time': '10:00-13:00', 'type': 'facturée', 'color': Colors.green},
    {'title': 'Congés', 'client': '-', 'consultantId': 4, 'date': '2024-05-08', 'time': 'Journée', 'type': 'congé', 'color': Colors.blue},
    {'title': 'Inter-contrat', 'client': '-', 'consultantId': 5, 'date': '2024-05-06', 'time': 'Journée', 'type': 'intercontrat', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredConsultants = List.from(_consultants);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Planificateur Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Carte des consultants',
            onPressed: () => _showMapDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Créer une mission',
            onPressed: () => _showCreateMissionDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Planning Hebdo'), Tab(text: 'Consultants')],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyPlanning(),
          _buildConsultantsListWithFilters(),
        ],
      ),
    );
  }

  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (_) => ConsultantMapDialog(consultants: _consultants),
    );
  }

  void _showCreateMissionDialog({int? consultantId}) {
    showDialog(
      context: context,
      builder: (_) => CreateMissionDialog(consultants: _consultants),
    );
  }

  Widget _buildWeeklyPlanning() {
    return MissionWeekView(consultants: _consultants, missions: _missions);
  }

  Widget _buildConsultantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredConsultants.length,
      itemBuilder: (_, index) {
        final c = _filteredConsultants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: c['color'] as Color, child: Text((c['name'] as String)[0], style: const TextStyle(color: Colors.white))),
            title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c['specialty']} • ${c['missions']} missions'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _getStatusColor(c['status'] as String), borderRadius: BorderRadius.circular(20)),
              child: Text(c['status'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            onTap: () => _showConsultantDetail(c),
          ),
        );
      },
    );
  }

  Widget _buildConsultantsListWithFilters() {
    return Column(
      children: [
        SkillFilterWidget(
          allConsultants: _consultants,
          onFilteredConsultants: (filtered) {
            setState(() => _filteredConsultants = filtered);
          },
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildConsultantsList()),
      ],
    );
  }

    mainAxisSize: MainAxisSize.min,
    children: [Container(width: 16, height: 16, color: color), const SizedBox(width: 4), Text(label)],
  );

  Widget _buildConsultantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _consultants.length,
      itemBuilder: (_, index) {
        final c = _consultants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: c['color'] as Color, child: Text((c['name'] as String)[0], style: const TextStyle(color: Colors.white))),
            title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c['specialty']} • ${c['missions']} missions'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _getStatusColor(c['status'] as String), borderRadius: BorderRadius.circular(20)),
              child: Text(c['status'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            onTap: () => _showConsultantDetail(c),
          ),
        );
      },
    );
  }

  void _showConsultantDetail(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            CircleAvatar(radius: 40, backgroundColor: c['color'], child: Text(c['name'][0], style: const TextStyle(fontSize: 30, color: Colors.white))),
            const SizedBox(height: 12),
            Text(c['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(c['specialty'], style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 28),
            _infoRow('Statut', c['status']),
            _infoRow('Missions', c['missions'].toString()),
            _infoRow('Disponibilité', c['status'] == 'disponible' ? 'Immédiate' : 'À vérifier'),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Fermer'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(context); _showCreateMissionDialog(consultantId: c['id']); },
                icon: const Icon(Icons.add_task),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                label: const Text('Assigner'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
  
  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
    ]),
  );

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible': return Colors.green;
      case 'en_mission': return Colors.orange;
      case 'congé': return Colors.blue;
      default: return Colors.grey;
    }
  }
}