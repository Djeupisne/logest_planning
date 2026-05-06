// lib/features/planner/presentation/pages/consultant_map_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ConsultantMapDialog extends StatelessWidget {
  final List<Map<String, dynamic>> consultants;
  const ConsultantMapDialog({super.key, required this.consultants});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              const Icon(Icons.map, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Localisation des consultants', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          // Carte
          Expanded(child: FlutterMap(
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
                markers: consultants.where((c) => c['id'] > 0).map((c) => Marker(
                  point: LatLng(c['lat'] ?? 12.1348, c['lng'] ?? 15.0557),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showConsultantInfo(context, c),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(c['status']),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                        ),
                        child: Text(c['name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                )).toList(),
              ),
            ],
          )),
          // Légende
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _legendItem('Disponible', Colors.green),
              _legendItem('En mission', Colors.orange),
              _legendItem('Congé', Colors.blue),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showConsultantInfo(BuildContext context, Map<String, dynamic> consultant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _getStatusColor(consultant['status']),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(consultant['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(consultant['specialty'] ?? '', style: TextStyle(color: Colors.grey[600])),
            ])),
          ]),
          const Divider(height: 24),
          _infoRow(Icons.work, '${consultant['missions']} missions'),
          const SizedBox(height: 8),
          _infoRow(Icons.info, 'Statut: ${consultant['status']}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Fermer'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 20, color: Colors.grey[600]),
    const SizedBox(width: 12),
    Text(text, style: const TextStyle(fontSize: 14)),
  ]);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible': return Colors.green;
      case 'en_mission': return Colors.orange;
      case 'congé': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _legendItem(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}
