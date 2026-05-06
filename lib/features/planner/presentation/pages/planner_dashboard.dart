// lib/features/planner/presentation/pages/planner_dashboard.dart
import 'package:flutter/material.dart';

class PlannerDashboard extends StatefulWidget {
  const PlannerDashboard({super.key});

  @override
  State<PlannerDashboard> createState() => _PlannerDashboardState();
}

class _PlannerDashboardState extends State<PlannerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Consultant> _consultants = [
    Consultant(id: 1, name: 'Jean Dupont', specialty: 'Réseau', status: 'disponible', color: Colors.green, missions: 3),
    Consultant(id: 2, name: "Marie N'Djamena", specialty: 'Développement', status: 'en_mission', color: Colors.orange, missions: 2),
    Consultant(id: 3, name: 'Ali Mahamat', specialty: 'Maintenance', status: 'disponible', color: Colors.blue, missions: 1),
    Consultant(id: 4, name: 'Fatima Hassan', specialty: 'Formation', status: 'congé', color: Colors.grey, missions: 0),
    Consultant(id: 5, name: 'Oumar Abakar', specialty: 'Consulting', status: 'disponible', color: Colors.purple, missions: 2),
  ];

  final List<PlanningMission> _missions = [
    PlanningMission(title: 'Installation réseau', client: 'Banque Sahélo-Saharienne', consultantId: 1, date: '2024-05-06', time: '09:00-12:00', type: 'facturée', color: Colors.green),
    PlanningMission(title: 'Formation Excel', client: 'Ministère Finances', consultantId: 2, date: '2024-05-06', time: '14:00-17:00', type: 'formation', color: Colors.yellow),
    PlanningMission(title: 'Maintenance serveur', client: 'Université', consultantId: 3, date: '2024-05-07', time: '10:00-13:00', type: 'facturée', color: Colors.green),
    PlanningMission(title: 'Congés', client: '-', consultantId: 4, date: '2024-05-08', time: 'Journée', type: 'congé', color: Colors.blue),
    PlanningMission(title: 'Inter-contrat', client: '-', consultantId: 5, date: '2024-05-06', time: 'Journée', type: 'intercontrat', color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Planificateur Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.map), onPressed: () => _showSuccess('Carte des consultants')),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateMissionDialog()),
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
          _buildConsultantsList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanning() {
    final days = ['Lundi 6', 'Mardi 7', 'Mercredi 8', 'Jeudi 9', 'Vendredi 10'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            SizedBox(
              width: 120,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 60),
                ..._consultants.map((c) => Container(
                  height: 80,
                  alignment: Alignment.centerLeft,
                  child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )),
              ]),
            ),
            Row(children: days.map((day) => SizedBox(
              width: 140,
              child: Column(children: [
                Container(
                  height: 50,
                  color: Colors.blue[50],
                  child: Center(child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
                ..._consultants.map((c) => Container(
                  height: 80,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
                  child: _getMissionsForDay(c.id, day),
                )),
              ]),
            )).toList()),
          ]),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ]),
    );
  }

  Widget _getMissionsForDay(int consultantId, String day) {
    final dayNum = day.split(' ')[1];
    final missions = _missions.where((m) => m.consultantId == consultantId && m.date.contains(dayNum)).toList();
    if (missions.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: missions.first.color.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
        child: Text(missions.first.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          const Text('Légende', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 16, children: [
            _legendItem('Facturée', Colors.green),
            _legendItem('Formation', Colors.yellow),
            _legendItem('Congé', Colors.blue),
            _legendItem('Inter-contrat', Colors.grey),
          ]),
        ]),
      ),
    );
  }

  Widget _legendItem(String label, Color color) => Row(
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
            leading: CircleAvatar(backgroundColor: c.color, child: Text(c.name[0], style: const TextStyle(color: Colors.white))),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c.specialty} • ${c.missions} missions'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _getStatusColor(c.status), borderRadius: BorderRadius.circular(20)),
              child: Text(c.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            onTap: () => _showConsultantDetail(c),
          ),
        );
      },
    );
  }

  void _showConsultantDetail(Consultant c) {
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
            CircleAvatar(radius: 40, backgroundColor: c.color, child: Text(c.name[0], style: const TextStyle(fontSize: 30, color: Colors.white))),
            const SizedBox(height: 12),
            Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(c.specialty, style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 28),
            _infoRow('Statut', c.status),
            _infoRow('Missions', c.missions.toString()),
            _infoRow('Disponibilité', c.status == 'disponible' ? 'Immédiate' : 'À vérifier'),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _showCreateMissionDialog(consultantId: c.id); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Assigner'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      Text(value),
    ]),
  );

  void _showCreateMissionDialog({int? consultantId}) => _showSuccess('Formulaire de création de mission');
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  Color _getStatusColor(String s) => {'disponible': Colors.green, 'en_mission': Colors.orange, 'congé': Colors.blue}[s] ?? Colors.grey;
}

class Consultant {
  final int id, missions;
  final String name, specialty, status;
  final Color color;
  Consultant({required this.id, required this.name, required this.specialty, required this.status, required this.color, required this.missions});
}

class PlanningMission {
  final String title, client, date, time, type;
  final int consultantId;
  final Color color;
  PlanningMission({required this.title, required this.client, required this.consultantId, required this.date, required this.time, required this.type, required this.color});
}