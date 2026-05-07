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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              const Icon(Icons.map, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Localisation des consultants',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),
          ),
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
                  point: LatLng(
                    (c['lat'] as num?)?.toDouble() ?? 12.1348,
                    (c['lng'] as num?)?.toDouble() ?? 15.0557,
                  ),
                  width: 40,
                  height: 56,
                  child: GestureDetector(
                    onTap: () => _showConsultantInfo(context, c),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(c['status'] as String? ?? ''),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                          ),
                          child: Text(
                            c['name'] as String? ?? '',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          )),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem('Disponible', Colors.green),
                _legendItem('En mission', Colors.orange),
                _legendItem('Congé', Colors.blue),
              ],
            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getStatusColor(consultant['status'] as String? ?? ''),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(consultant['name'] as String? ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(consultant['specialty'] as String? ?? '', style: TextStyle(color: Colors.grey[600])),
                ],
              )),
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
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 20, color: Colors.grey[600]),
    const SizedBox(width: 12),
    Flexible(child: Text(text, style: const TextStyle(fontSize: 14))),
  ]);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible': return Colors.green;
      case 'en_mission': return Colors.orange;
      case 'congé': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _legendItem(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Flexible(child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
    ],
  );
}