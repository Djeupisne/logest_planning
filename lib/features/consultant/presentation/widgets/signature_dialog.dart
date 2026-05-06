// lib/features/consultant/presentation/widgets/signature_dialog.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class SignatureDialog extends StatefulWidget {
  final int missionId;
  const SignatureDialog({super.key, required this.missionId});

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final List<Offset?> _points = [];
  bool _hasSignature = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Signature client'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez faire signer le client ci-dessous :', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onPanStart: (details) => setState(() => _points.add(details.localPosition)),
                onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
                onPanEnd: (_) => setState(() => _points.add(null)),
                child: CustomPaint(
                  painter: SignaturePainter(points: _points),
                  size: const Size(300, 200),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () => setState(() => _points.clear()),
                child: const Text('Effacer'),
              ),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _points.isEmpty ? null : _saveSignature,
          child: const Text('Valider'),
        ),
      ],
    );
  }

  void _saveSignature() async {
    // Simulation de sauvegarde
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signature enregistrée avec succès')));
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
