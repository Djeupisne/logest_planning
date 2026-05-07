import 'package:flutter/material.dart';

class SkillFilterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> allConsultants;
  final Function(List<Map<String, dynamic>>) onFilteredConsultants;
  const SkillFilterWidget({
    super.key,
    required this.allConsultants,
    required this.onFilteredConsultants,
  });
  @override
  State<SkillFilterWidget> createState() => _SkillFilterWidgetState();
}

class _SkillFilterWidgetState extends State<SkillFilterWidget> {
  String _selectedSkill = 'Tous';
  String _selectedStatus = 'Tous';
  final List<String> _skills = [
    'Tous',
    'Réseau',
    'Développement',
    'Maintenance',
    'Formation',
    'Consulting',
  ];
  final List<String> _statuses = [
    'Tous',
    'disponible',
    'en_mission',
    'congé',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = widget.allConsultants;
    if (_selectedSkill != 'Tous') {
      filtered = filtered.where((c) => c['specialty'] == _selectedSkill).toList();
    }
    if (_selectedStatus != 'Tous') {
      filtered = filtered.where((c) => c['status'] == _selectedStatus).toList();
    }
    widget.onFilteredConsultants(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFF1976D2)),
              const SizedBox(width: 8),
              const Text(
                'Filtres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_selectedSkill != 'Tous' || _selectedStatus != 'Tous')
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedSkill = 'Tous';
                      _selectedStatus = 'Tous';
                    });
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Effacer'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipGroup(
                title: 'Compétence:',
                selectedValue: _selectedSkill,
                values: _skills,
                onSelected: (value) {
                  setState(() => _selectedSkill = value);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 8),
              _buildChipGroup(
                title: 'Statut:',
                selectedValue: _selectedStatus,
                values: _statuses,
                onSelected: (value) {
                  setState(() => _selectedStatus = value);
                  _applyFilters();
                },
                statusColors: {
                  'Tous': Colors.grey,
                  'disponible': Colors.green,
                  'en_mission': Colors.orange,
                  'congé': Colors.blue,
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.allConsultants.length} consultant(s) au total → ${_getFilteredCount()} affiché(s)',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1976D2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup({
    required String title,
    required String selectedValue,
    required List<String> values,
    required Function(String) onSelected,
    Map<String, Color>? statusColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values.map((value) {
            final isSelected = selectedValue == value;
            final color = statusColors?[value] ?? const Color(0xFF1976D2);
            return FilterChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              backgroundColor: Colors.grey[100],
              selectedColor: color.withOpacity(0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  int _getFilteredCount() {
    var filtered = widget.allConsultants;
    if (_selectedSkill != 'Tous') {
      filtered = filtered.where((c) => c['specialty'] == _selectedSkill).toList();
    }
    if (_selectedStatus != 'Tous') {
      filtered = filtered.where((c) => c['status'] == _selectedStatus).toList();
    }
    return filtered.length;
  }
}

class SmartAssignmentWidget extends StatelessWidget {
  final List<Map<String, dynamic>> consultants;
  final String? requiredSkill;
  final Function(int consultantId) onConsultantSelected;
  const SmartAssignmentWidget({
    super.key,
    required this.consultants,
    this.requiredSkill,
    required this.onConsultantSelected,
  });
  @override
  Widget build(BuildContext context) {
    final sortedConsultants = List<Map<String, dynamic>>.from(consultants);
    sortedConsultants.sort((a, b) {
      final aHasSkill = requiredSkill == null || a['specialty'] == requiredSkill;
      final bHasSkill = requiredSkill == null || b['specialty'] == requiredSkill;
      if (aHasSkill && !bHasSkill) return -1;
      if (!aHasSkill && bHasSkill) return 1;
      final aAvailable = a['status'] == 'disponible';
      final bAvailable = b['status'] == 'disponible';
      if (aAvailable && !bAvailable) return -1;
      if (!aAvailable && bAvailable) return 1;
      return 0;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requiredSkill != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compétence requise: $requiredSkill',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...sortedConsultants.map((consultant) => _buildConsultantTile(consultant)),
      ],
    );
  }

  Widget _buildConsultantTile(Map<String, dynamic> consultant) {
    final hasRequiredSkill = requiredSkill == null || consultant['specialty'] == requiredSkill;
    final isAvailable = consultant['status'] == 'disponible';
    Color statusColor;
    switch (consultant['status']) {
      case 'disponible': statusColor = Colors.green; break;
      case 'en_mission': statusColor = Colors.orange; break;
      case 'congé': statusColor = Colors.blue; break;
      default: statusColor = Colors.grey;
    }
    return ListTile(
      enabled: isAvailable && hasRequiredSkill,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: (consultant['color'] as Color?) ?? Colors.grey,
            child: Text(
              (consultant['name'] as String)[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (!hasRequiredSkill)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.warning, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Text(
        consultant['name'] as String,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decoration: !hasRequiredSkill ? TextDecoration.lineThrough : null,
          decorationColor: Colors.grey,
        ),
      ),
      subtitle: Text(
        '${consultant['specialty']} • ${(consultant['missions'] as int?) ?? 0} missions',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Text(
          consultant['status'] as String,
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: isAvailable && hasRequiredSkill
          ? () => onConsultantSelected(consultant['id'] as int)
          : null,
    );
  }
}