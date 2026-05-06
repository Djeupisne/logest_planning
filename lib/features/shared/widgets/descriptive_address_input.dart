import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/descriptive_address.dart';
import '../../core/services/haptic_service.dart';

/// Widget pour saisir une adresse descriptive adaptée au contexte tchadien
/// Permet de sélectionner quartier, points de repère et coordonnées GPS
class DescriptiveAddressInput extends StatefulWidget {
  final DescriptiveAddress? initialValue;
  final ValueChanged<DescriptiveAddress>? onChanged;
  final bool showCoordinatesPicker;
  final bool showLandmarkSuggestions;

  const DescriptiveAddressInput({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.showCoordinatesPicker = true,
    this.showLandmarkSuggestions = true,
  }) : super(key: key);

  @override
  State<DescriptiveAddressInput> createState() => _DescriptiveAddressInputState();
}

class _DescriptiveAddressInputState extends State<DescriptiveAddressInput> {
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _additionalInfoController;
  late List<String> _selectedLandmarks;
  double? _latitude;
  double? _longitude;
  
  final HapticService _hapticService = HapticService();
  bool _showNeighborhoodDropdown = false;
  bool _showLandmarkSuggestions = false;

  @override
  void initState() {
    super.initState();
    _neighborhoodController = TextEditingController(text: widget.initialValue?.neighborhood ?? '');
    _cityController = TextEditingController(text: widget.initialValue?.city ?? 'N\'Djaména');
    _streetController = TextEditingController(text: widget.initialValue?.streetName ?? '');
    _buildingController = TextEditingController(text: widget.initialValue?.buildingNumber ?? '');
    _additionalInfoController = TextEditingController(text: widget.initialValue?.additionalInfo ?? '');
    _selectedLandmarks = List.from(widget.initialValue?.landmarks ?? []);
    _latitude = widget.initialValue?.latitude;
    _longitude = widget.initialValue?.longitude;
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    if (widget.onChanged != null && _neighborhoodController.text.isNotEmpty) {
      final address = DescriptiveAddress(
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        streetName: _streetController.text.isEmpty ? null : _streetController.text,
        buildingNumber: _buildingController.text.isEmpty ? null : _buildingController.text,
        landmarks: _selectedLandmarks,
        additionalInfo: _additionalInfoController.text.isEmpty ? null : _additionalInfoController.text,
        latitude: _latitude,
        longitude: _longitude,
      );
      widget.onChanged!(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Adresse du lieu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ville
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Ville',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 12),

            // Quartier avec suggestions
            Focus(
              onFocusChange: (hasFocus) {
                setState(() => _showNeighborhoodDropdown = hasFocus);
              },
              child: TextField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  labelText: 'Quartier *',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () => setState(() => _showNeighborhoodDropdown = !_showNeighborhoodDropdown),
                  ),
                  helperText: 'Ex: Moursal, Chagoua, Dembé...',
                ),
                onChanged: (_) {
                  _notifyParent();
                  setState(() {});
                },
              ),
            ),
            
            // Suggestions de quartiers
            if (_showNeighborhoodDropdown && widget.initialValue == null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LandmarkHelper.ndjamenaNeighborhoods.map((neighborhood) {
                  return ActionChip(
                    label: Text(neighborhood, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _hapticService.lightClick();
                      _neighborhoodController.text = neighborhood;
                      setState(() => _showNeighborhoodDropdown = false);
                      _notifyParent();
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),

            // Rue et numéro (optionnels)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _streetController,
                    decoration: InputDecoration(
                      labelText: 'Rue (optionnel)',
                      prefixIcon: const Icon(Icons.streetview),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => _notifyParent(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _buildingController,
                    decoration: InputDecoration(
                      labelText: 'N° (optionnel)',
                      prefixIcon: const Icon(Icons.home),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => _notifyParent(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Points de repère
            Text(
              'Points de repère *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (_selectedLandmarks.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedLandmarks.map((landmark) {
                  return Chip(
                    label: Text(landmark, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      _hapticService.lightClick();
                      setState(() => _selectedLandmarks.remove(landmark));
                      _notifyParent();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Bouton ajouter point de repère
            OutlinedButton.icon(
              onPressed: () => _showAddLandmarkDialog(),
              icon: const Icon(Icons.add_location),
              label: const Text('Ajouter un point de repère'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Coordonnées GPS
            if (widget.showCoordinatesPicker) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitude != null && _longitude != null
                          ? 'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                          : 'Coordonnées GPS non définies',
                      style: TextStyle(
                        color: _latitude != null 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickCoordinates,
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Définir'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Informations complémentaires
            TextField(
              controller: _additionalInfoController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Informations complémentaires',
                hintText: 'Ex: Porte bleue, 2ème étage...',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _notifyParent(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddLandmarkDialog() async {
    _hapticService.mediumTap();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un point de repère'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: LandmarkHelper.commonLandmarks.length,
            itemBuilder: (context, index) {
              final landmark = LandmarkHelper.commonLandmarks[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(landmark),
                onTap: () {
                  _hapticService.lightClick();
                  if (!_selectedLandmarks.contains(landmark)) {
                    setState(() => _selectedLandmarks.add(landmark));
                    _notifyParent();
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCoordinates() async {
    _hapticService.mediumTap();
    
    // Simulation - Dans une vraie implémentation, ouvrir la carte
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner sur la carte'),
        content: const Text('Ouvrir la carte interactive pour sélectionner les coordonnées GPS.'),
        actions: [
          TextButton(
            onPressed: () {
              // Simulation: définir des coordonnées par défaut
              setState(() {
                _latitude = 12.1348;
                _longitude = 15.0544;
              });
              _notifyParent();
              Navigator.pop(context);
            },
            child: const Text('Utiliser position actuelle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
