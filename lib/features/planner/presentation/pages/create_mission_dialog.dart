// lib/features/planner/presentation/pages/create_mission_dialog.dart
import 'package:flutter/material.dart';

class CreateMissionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> consultants;
  const CreateMissionDialog({super.key, required this.consultants});

  @override
  State<CreateMissionDialog> createState() => _CreateMissionDialogState();
}

class _CreateMissionDialogState extends State<CreateMissionDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _titre, _client, _adresse, _contact, _phone;
  DateTime? _date;
  TimeOfDay? _startTime, _endTime;
  int? _consultantId;
  String _type = 'facturée';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle mission'),
      content: SizedBox(width: 400, child: SingleChildScrollView(
        child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(decoration: const InputDecoration(labelText: 'Titre'), onSaved: (v) => _titre = v, validator: (v) => v!.isEmpty ? 'Requis' : null),
          TextFormField(decoration: const InputDecoration(labelText: 'Client'), onSaved: (v) => _client = v, validator: (v) => v!.isEmpty ? 'Requis' : null),
          TextFormField(decoration: const InputDecoration(labelText: 'Adresse'), onSaved: (v) => _adresse = v),
          TextFormField(decoration: const InputDecoration(labelText: 'Contact'), onSaved: (v) => _contact = v),
          TextFormField(decoration: const InputDecoration(labelText: 'Téléphone'), onSaved: (v) => _phone = v),
          ListTile(title: const Text('Date'), subtitle: Text(_date == null ? 'Sélectionner' : '${_date!.day}/${_date!.month}/${_date!.year}'), onTap: () async {
            final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
            if (d != null) setState(() => _date = d);
          }),
          Row(children: [
            Expanded(child: ListTile(title: const Text('Début'), subtitle: Text(_startTime == null ? '--:--' : _startTime!.format(context)), onTap: () async {
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (t != null) setState(() => _startTime = t);
            })),
            Expanded(child: ListTile(title: const Text('Fin'), subtitle: Text(_endTime == null ? '--:--' : _endTime!.format(context)), onTap: () async {
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (t != null) setState(() => _endTime = t);
            })),
          ]),
          DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Type'), value: _type, items: const [
            DropdownMenuItem(value: 'facturée', child: Text('Facturée (vert)')),
            DropdownMenuItem(value: 'intercontrat', child: Text('Inter-contrat (gris)')),
            DropdownMenuItem(value: 'formation', child: Text('Formation (jaune)')),
          ], onChanged: (v) => setState(() => _type = v!)),
          DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Consultant'), items: widget.consultants.where((c) => c['id'] > 0).map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']))).toList(),
            onChanged: (v) => _consultantId = v, validator: (v) => v == null ? 'Requis' : null),
        ])),
      )),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission créée avec succès')));
          }
        }, child: const Text('Créer')),
      ],
    );
  }
}
