// lib/features/consultant/presentation/widgets/incident_report_dialog.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IncidentReportDialog extends StatefulWidget {
  final int missionId;
  const IncidentReportDialog({super.key, required this.missionId});

  @override
  State<IncidentReportDialog> createState() => _IncidentReportDialogState();
}

class _IncidentReportDialogState extends State<IncidentReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident signalé avec succès')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Signaler un incident'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type d\'incident'),
              items: ['Retard', 'Problème technique', 'Client absent', 'Autre'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => _typeController.text = v ?? '',
              validator: (v) => v == null ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'Description requise' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _image != null ? Image.file(_image!, height: 80) : Container(height: 80, color: Colors.grey[200])),
              IconButton(onPressed: _pickImage, icon: const Icon(Icons.camera_alt)),
            ]),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(onPressed: _submit, child: const Text('Envoyer')),
      ],
    );
  }
}
