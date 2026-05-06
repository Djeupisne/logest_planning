// lib/features/consultant/presentation/widgets/mission_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/mission_bloc.dart';
import '../../domain/entities/mission.dart';
import 'incident_report_dialog.dart';
import 'signature_dialog.dart';

class MissionCard extends StatefulWidget {
  final Mission mission;
  const MissionCard({super.key, required this.mission});

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        ListTile(
          onTap: () => setState(() => _expanded = !_expanded),
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(widget.mission.status),
            child: Text(widget.mission.title[0]),
          ),
          title: Text(widget.mission.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${_formatTime(widget.mission.scheduledStart)} - ${_formatTime(widget.mission.scheduledEnd)}'),
          trailing: Chip(
            label: Text(_getStatusLabel(widget.mission.status)),
            backgroundColor: _getStatusColor(widget.mission.status).withOpacity(0.2),
          ),
        ),
        if (_expanded) Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.location_on, size: 16), const SizedBox(width: 4), Expanded(child: Text(widget.mission.address))]),
            const SizedBox(height: 8),
            if (widget.mission.contactName != null) Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 4), Text(widget.mission.contactName!)]),
            if (widget.mission.contactPhone != null) Row(children: [const Icon(Icons.phone, size: 16), const SizedBox(width: 4), Text(widget.mission.contactPhone!)]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              if (widget.mission.latitude != null) ElevatedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Itinéraire'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              if (widget.mission.status != 'completed') _buildStatusButton(),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => IncidentReportDialog(missionId: widget.mission.id)),
                icon: const Icon(Icons.report, size: 18),
                label: const Text('Incident'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              if (widget.mission.requiresSignature) ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => SignatureDialog(missionId: widget.mission.id)),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Signature'),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStatusButton() {
    const nextStatus = {'en_route': 'arrived', 'arrived': 'in_progress', 'in_progress': 'completed'};
    final next = nextStatus[widget.mission.status] ?? 'en_route';
    return ElevatedButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Changer de statut'),
          content: Text('Passer à "${_getStatusLabel(next)}" ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                context.read<MissionBloc>().add(UpdateStatus(widget.mission.id, next));
                Navigator.pop(context);
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
      icon: Icon(_getStatusIcon(next), size: 18),
      label: Text(_getStatusLabel(next)),
      style: ElevatedButton.styleFrom(backgroundColor: _getStatusColor(next)),
    );
  }

  void _openMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.mission.latitude},${widget.mission.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  String _getStatusLabel(String s) => {'en_route': 'En route', 'arrived': 'Arrivé', 'in_progress': 'En intervention', 'completed': 'Terminé'}[s] ?? s;
  Color _getStatusColor(String s) => {'en_route': Colors.orange, 'arrived': Colors.blue, 'in_progress': Colors.green, 'completed': const Color(0xFF0F9D58)}[s] ?? Colors.grey;
  IconData _getStatusIcon(String s) => {'en_route': Icons.directions_car, 'arrived': Icons.location_on, 'in_progress': Icons.build, 'completed': Icons.check_circle}[s] ?? Icons.help;
}