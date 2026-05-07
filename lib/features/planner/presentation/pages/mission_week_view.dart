// lib/features/planner/presentation/pages/mission_week_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget de planning hebdomadaire détaillé (J+1 à J+5)
class MissionWeekView extends StatefulWidget {
  final List<Map<String, dynamic>> consultants;
  final List<Map<String, dynamic>> missions;
  
  const MissionWeekView({
    super.key,
    required this.consultants,
    required this.missions,
  });

  @override
  State<MissionWeekView> createState() => _MissionWeekViewState();
}

class _MissionWeekViewState extends State<MissionWeekView> {
  late List<DateTime> _weekDays;
  int _expandedDayIndex = -1;

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    // Commencer à J+1 (demain)
    _weekDays = List.generate(5, (index) {
      return DateTime(now.year, now.month, now.day + index + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ..._weekDays.asMap().entries.map((entry) => _buildDayCard(entry.key, entry.value)),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_view_week, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Planning Hebdomadaire',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'J+1 à J+5',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int index, DateTime day) {
    final dayMissions = widget.missions.where((m) {
      final missionDate = m['date'] is DateTime 
          ? m['date'] as DateTime 
          : DateTime.parse(m['date'].toString());
      return missionDate.year == day.year && 
             missionDate.month == day.month && 
             missionDate.day == day.day;
    }).toList();

    final isExpanded = _expandedDayIndex == index;
    final dayName = DateFormat('EEEE', 'fr_FR').format(day);
    final dayDate = DateFormat('dd/MM/yyyy').format(day);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedDayIndex = isExpanded ? -1 : index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getDayColor(index).withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(isExpanded ? 16 : 16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getDayColor(index),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat.MMM('fr_FR').format(day).substring(0, 3),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName[0].toUpperCase() + dayName.substring(1),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$dayDate • ${dayMissions.length} mission${dayMissions.length > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (dayMissions.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('Aucune mission prévue', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  else
                    ...dayMissions.map((mission) => _buildMissionTile(mission)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionTile(Map<String, dynamic> mission) {
    final consultant = widget.consultants.firstWhere(
      (c) => c['id'] == mission['consultantId'],
      orElse: () => {'name': 'Non assigné', 'color': Colors.grey},
    );

    final typeColors = {
      'facturée': Colors.green,
      'formation': Colors.orange,
      'congé': Colors.blue,
      'intercontrat': Colors.grey,
    };

    final typeColor = typeColors[mission['type']] ?? Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mission['client'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      mission['time'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: consultant['color'] as Color? ?? Colors.grey,
                      child: Text(
                        (consultant['name'] as String)[0],
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      consultant['name'] as String,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        mission['type'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Légende', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem('Facturée', Colors.green),
                _legendItem('Formation', Colors.orange),
                _legendItem('Congé', Colors.blue),
                _legendItem('Inter-contrat', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Color _getDayColor(int index) {
    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
      const Color(0xFF7B1FA2),
      const Color(0xFFC62828),
    ];
    return colors[index % colors.length];
  }
}
