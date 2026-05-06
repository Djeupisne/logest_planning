// lib/features/consultant/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';

class ConsultantProfilePage extends StatelessWidget {
  const ConsultantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text('Jean Dupont', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Consultant senior', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _buildInfoCard('Informations personnelles', [
              _infoRow('Email', 'jean.dupont@logest.com'),
              _infoRow('Téléphone', '+235 66 12 34 56'),
              _infoRow('Spécialité', 'Réseaux & Infrastructure'),
              _infoRow('Date d\'entrée', '01/01/2023'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Statistiques', [
              _infoRow('Missions réalisées', '42'),
              _infoRow('Taux de ponctualité', '98%'),
              _infoRow('Satisfaction client', '4.8/5'),
              _infoRow('Jours de congé', '12/25'),
            ]),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: () => _showLogoutDialog(context), icon: const Icon(Icons.logout), label: const Text('Se déconnecter'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Divider(), ...children])),
    );
  }

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));

  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Déconnexion'), content: const Text('Voulez-vous vraiment vous déconnecter ?'), actions: [TextButton(onPressed: () => Navigator.pop(_), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Se déconnecter', style: TextStyle(color: Colors.red))) ]));
  }
}
