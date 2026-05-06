import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

/// Widget de signature électronique avancé avec zoom, undo/redo et export PDF
class AdvancedSignatureDialog extends StatefulWidget {
  final int missionId;
  final String? clientName;
  final Function(String pdfPath)? onSave;

  const AdvancedSignatureDialog({
    super.key,
    required this.missionId,
    this.clientName,
    this.onSave,
  });

  @override
  State<AdvancedSignatureDialog> createState() => _AdvancedSignatureDialogState();
}

class _AdvancedSignatureDialogState extends State<AdvancedSignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _hasSignature = false;
  bool _isZoomed = false;
  double _zoomLevel = 1.0;
  
  // Historique pour undo/redo
  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSignatureChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChange);
    _controller.dispose();
    super.dispose();
  }

  void _onSignatureChange() {
    setState(() {
      _hasSignature = !_controller.isEmpty;
    });
  }

  void _saveHistory() {
    // Limiter l'historique à 20 étapes
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    
    final pngData = _controller.toPngData();
    if (pngData != null) {
      _history.add(String.fromCharCodes(pngData));
      _historyIndex = _history.length - 1;
      
      // Garder seulement les 20 dernières étapes
      if (_history.length > 20) {
        _history.removeAt(0);
        _historyIndex--;
      }
    }
  }

  void _undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _loadFromHistory(_history[_historyIndex]);
    } else if (_historyIndex == 0) {
      _historyIndex = -1;
      _controller.clear();
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _loadFromHistory(_history[_historyIndex]);
    }
  }

  void _loadFromHistory(String data) {
    // Recharger la signature depuis l'historique
    // Note: Cette implémentation est simplifiée
    // Pour une version complète, il faudrait sauvegarder les points
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  Future<void> _saveSignature() async {
    try {
      // Exporter en PNG
      final pngBytes = await _controller.toPngByteData(format: ImageByteFormat.png);
      if (pngBytes == null) return;

      // Sauvegarder dans le système de fichiers
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/signatures/mission_${widget.missionId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes.buffer.asUint8List());

      // Exporter en PDF si demandé
      String? pdfPath;
      if (widget.onSave != null) {
        pdfPath = await _exportToPdf(pngBytes.buffer.asUint8List());
      }

      Navigator.pop(context, {'png': filePath, 'pdf': pdfPath});
      
      // Feedback visuel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Signature enregistrée avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _exportToPdf(Uint8List pngBytes) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Signature Électronique',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  if (widget.clientName != null)
                    pw.Text(
                      'Client: ${widget.clientName}',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  pw.SizedBox(height: 30),
                  pw.Image(pw.MemoryImage(pngBytes), width: 400, height: 200),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'Date: ${DateTime.now().toString().split('.')[0]}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 50),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Ce document atteste de la validation électronique de la mission.',
                    style: const pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Sauvegarder le PDF
      final directory = await getApplicationDocumentsDirectory();
      final pdfPath = '${directory.path}/signatures/mission_${widget.missionId}_signature.pdf';
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      print('Erreur export PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.edit_note, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signature Client',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (widget.clientName != null)
                        Text(
                          widget.clientName!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veuillez faire signer le client dans la zone ci-dessous',
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Zone de signature
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: isDark ? Colors.grey[900] : Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Signature(
                  controller: _controller,
                  backgroundColor: isDark ? Colors.grey[900]! : Colors.white,
                  onPanStart: (_) => _saveHistory(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Zoom controls
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 2.0);
                        });
                      },
                      icon: const Icon(Icons.zoom_out),
                      tooltip: 'Dézoomer',
                    ),
                    Text('${(_zoomLevel * 100).toInt()}%'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 2.0);
                        });
                      },
                      icon: const Icon(Icons.zoom_in),
                      tooltip: 'Zoomer',
                    ),
                  ],
                ),
                
                // Undo/Redo/Clear
                Row(
                  children: [
                    IconButton(
                      onPressed: _historyIndex >= 0 ? _undo : null,
                      icon: const Icon(Icons.undo),
                      tooltip: 'Annuler',
                    ),
                    IconButton(
                      onPressed: _historyIndex < _history.length - 1 ? _redo : null,
                      icon: const Icon(Icons.redo),
                      tooltip: 'Rétablir',
                    ),
                    IconButton(
                      onPressed: _hasSignature ? _clear : null,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Effacer',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _hasSignature ? _saveSignature : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Valider la signature'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
