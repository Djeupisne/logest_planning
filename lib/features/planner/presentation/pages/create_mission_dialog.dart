// lib/features/planner/presentation/pages/create_mission_dialog.dart
import 'package:flutter/material.dart';

class CreateMissionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> consultants;
  final Map<String, dynamic>? initialData;
  
  const CreateMissionDialog({
    super.key, 
    required this.consultants,
    this.initialData,
  });

  @override
  State<CreateMissionDialog> createState() => _CreateMissionDialogState();
}

class _CreateMissionDialogState extends State<CreateMissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  DateTime? _date;
  TimeOfDay? _startTime, _endTime;
  int? _consultantId;
  String _type = 'facturée';
  String _competence = 'Tous';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Mode édition : pré-remplir les champs
      _titleCtrl.text = widget.initialData!['title'] ?? '';
      _clientCtrl.text = widget.initialData!['client'] ?? '';
      _addressCtrl.text = widget.initialData!['address'] ?? '';
      _contactCtrl.text = widget.initialData!['contact'] ?? '';
      _phoneCtrl.text = widget.initialData!['phone'] ?? '';
      _descCtrl.text = widget.initialData!['description'] ?? '';
      _consultantId = widget.initialData!['consultantId'];
      _type = widget.initialData!['type'] ?? 'facturée';
      
      // Parser la date
      if (widget.initialData!['date'] != null) {
        try {
          _date = DateTime.parse(widget.initialData!['date'].toString());
        } catch (_) {}
      }
      
      // Parser l'horaire (format "09:00-12:00")
      if (widget.initialData!['time'] != null) {
        final timeStr = widget.initialData!['time'].toString();
        final parts = timeStr.split('-');
        if (parts.length == 2) {
          try {
            final startParts = parts[0].trim().split(':');
            final endParts = parts[1].trim().split(':');
            _startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
            _endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
          } catch (_) {}
        }
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _clientCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.initialData != null ? const Color(0xFF388E3C) : const Color(0xFF1976D2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(children: [
              Icon(widget.initialData != null ? Icons.edit : Icons.add_task, color: Colors.white),
              const SizedBox(width: 12),
              Text(widget.initialData != null ? 'Modifier la mission' : 'Nouvelle mission', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          // Formulaire
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Section: Informations générales
              _sectionTitle('Informations générales'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre de la mission', prefixIcon: Icon(Icons.work)),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clientCtrl,
                decoration: const InputDecoration(labelText: 'Client', prefixIcon: Icon(Icons.business)),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Adresse', prefixIcon: Icon(Icons.location_on)),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // Section: Contact
              _sectionTitle('Contact client'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _contactCtrl,
                  decoration: const InputDecoration(labelText: 'Nom contact', prefixIcon: Icon(Icons.person)),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                )),
              ]),
              const SizedBox(height: 20),
              
              // Section: Planification
              _sectionTitle('Planification'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2))), child: child!),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
                    child: Text(_date == null ? 'Sélectionner' : '${_date!.day}/${_date!.month}/${_date!.year}'),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category)),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'facturée', child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Facturée')])),
                    DropdownMenuItem(value: 'intercontrat', child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Inter-contrat')])),
                    DropdownMenuItem(value: 'formation', child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Formation')])),
                    DropdownMenuItem(value: 'congé', child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Congé')])),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2))), child: child!));
                    if (t != null) setState(() => _startTime = t);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Heure début', prefixIcon: Icon(Icons.access_time)),
                    child: Text(_startTime == null ? '--:--' : _startTime!.format(context)),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2))), child: child!));
                    if (t != null) setState(() => _endTime = t);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Heure fin', prefixIcon: Icon(Icons.access_time)),
                    child: Text(_endTime == null ? '--:--' : _endTime!.format(context)),
                  ),
                )),
              ]),
              const SizedBox(height: 20),
              
              // Section: Affectation
              _sectionTitle('Affectation'),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Consultant', prefixIcon: Icon(Icons.person_outline)),
                value: _consultantId,
                hint: const Text('Sélectionner un consultant'),
                items: widget.consultants.where((c) => c['id'] != null).map((c) {
                  final name = c['name'] as String;
                  final status = c['status'] as String;
                  return DropdownMenuItem(
                    value: c['id'] as int,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      CircleAvatar(radius: 12, backgroundColor: _getConsultantColor(status), child: Text(name[0], style: const TextStyle(fontSize: 10, color: Colors.white))),
                      const SizedBox(width: 8),
                      Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Text(status, style: TextStyle(fontSize: 9, color: _getStatusColor(status)))),
                    ]),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _consultantId = v),
                validator: (v) => v == null ? 'Consultant requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Compétence requise', prefixIcon: Icon(Icons.school)),
                value: _competence,
                items: ['Tous', 'Réseau', 'Développement', 'Maintenance', 'Formation', 'Consulting'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _competence = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description / Instructions', prefixIcon: Icon(Icons.description), alignLabelWithHint: true),
                maxLines: 3,
              ),
            ])),
          )),
          // Footer avec boutons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: Text(widget.initialData != null ? 'Annuler' : 'Annuler'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700]),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(widget.initialData != null ? Icons.save : Icons.check),
                label: Text(widget.initialData != null ? 'Enregistrer' : 'Créer la mission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.initialData != null ? const Color(0xFF388E3C) : const Color(0xFF1976D2),
                ),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Row(children: [
    Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
  ]);

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Simuler la création ou modification
      Navigator.pop(context, true); // Retourne true pour indiquer le succès
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(widget.initialData != null ? Icons.save : Icons.check_circle, color: Colors.white), 
            const SizedBox(width: 12), 
            Text(widget.initialData != null ? 'Mission modifiée avec succès' : 'Mission créée avec succès')
          ]),
          backgroundColor: widget.initialData != null ? const Color(0xFF388E3C) : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
    }
  }

  Color _getConsultantColor(String status) {
    switch (status) {
      case 'disponible': return Colors.green;
      case 'en_mission': return Colors.orange;
      case 'congé': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible': return Colors.green;
      case 'en_mission': return Colors.orange;
      case 'congé': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
