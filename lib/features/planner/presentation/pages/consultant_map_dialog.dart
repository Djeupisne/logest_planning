// lib/features/planner/presentation/pages/consultant_map_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConsultantMapDialog extends StatefulWidget {
  final List<Map<String, dynamic>> consultants;
  const ConsultantMapDialog({super.key, required this.consultants});

  @override
  State<ConsultantMapDialog> createState() => _ConsultantMapDialogState();
}

class _ConsultantMapDialogState extends State<ConsultantMapDialog> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    for (var c in widget.consultants.where((c) => c['id'] > 0)) {
      _markers.add(Marker(
        markerId: MarkerId(c['id'].toString()),
        position: LatLng(c['lat'], c['lng']),
        infoWindow: InfoWindow(title: c['name'], snippet: 'Statut: ${c['status']}'),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(width: 500, height: 500,
        child: GoogleMap(
          onMapCreated: (c) => _controller = c,
          initialCameraPosition: const CameraPosition(target: LatLng(12.1348, 15.0557), zoom: 12),
          markers: _markers,
          myLocationEnabled: true,
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
    );
  }
}
