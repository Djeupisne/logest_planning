// lib/features/direction/presentation/pages/direction_home.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DirectionHome extends StatefulWidget {
  const DirectionHome({super.key});

  @override
  State<DirectionHome> createState() => _DirectionHomeState();
}

class _DirectionHomeState extends State<DirectionHome> {
  int _selectedPeriod = 0;
  final List<double> _utilData = [68, 72, 75, 80, 78, 82, 85, 88, 87, 84, 82, 79];
  final List<double> _realData = [230, 245, 260, 275, 290, 305, 320, 335, 350, 365, 380, 395];
  final List<double> _estData = [240, 255, 270, 285, 300, 315, 330, 345, 360, 375, 390, 405];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Direction Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exporter CSV',
            onPressed: () => _exportCSV(),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimer',
            onPressed: () => _showSuccess('Impression lancée'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              _buildPeriodButton('Trimestre', 0),
              _buildPeriodButton('Semestre', 1),
              _buildPeriodButton('Année', 2),
            ]),
            const SizedBox(height: 24),
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              children: [
                _buildKpiCard('Taux utilisation', '82%', Icons.trending_up, Colors.green, '+5%', 'vs mois dernier'),
                _buildKpiCard('Missions terminées', '156', Icons.check_circle, Colors.blue, '+12', 'vs mois dernier'),
                _buildKpiCard('Retards signalés', '8', Icons.warning, Colors.orange, '-3', 'vs mois dernier'),
                _buildKpiCard('Consultants actifs', '12', Icons.people, Colors.purple, '+2', 'nouveaux'),
              ],
            ),
            const SizedBox(height: 24),
            Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                const Text('Taux d\'utilisation des consultants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(height: 250, child: LineChart(LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      if (v.toInt() >= 0 && v.toInt() < _utilData.length) return Text(['J','F','M','A','M','J','J','A','S','O','N','D'][v.toInt()]);
                      return const Text('');
                    }, reservedSize: 30)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [LineChartBarData(spots: _utilData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), isCurved: true, color: Colors.blue, barWidth: 3, belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)))],
                ))),
              ])),
            ),
            const SizedBox(height: 24),
            Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                const Text('Suivi des temps (heures)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(height: 250, child: LineChart(LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      if (v.toInt() >= 0 && v.toInt() < _realData.length) return Text(['J','F','M','A','M','J','J','A','S','O','N','D'][v.toInt()]);
                      return const Text('');
                    }, reservedSize: 30)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(spots: _estData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), isCurved: true, color: Colors.blue, barWidth: 3),
                    LineChartBarData(spots: _realData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), isCurved: true, color: Colors.orange, barWidth: 3),
                  ],
                ))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(children: [Container(width: 16, height: 16, color: Colors.blue), const SizedBox(width: 4), const Text('Estimé')]),
                  const SizedBox(width: 24),
                  Row(children: [Container(width: 16, height: 16, color: Colors.orange), const SizedBox(width: 4), const Text('Réel')]),
                ]),
              ])),
            ),
            const SizedBox(height: 24),
            Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                const Text('Synthèse annuelle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  _buildStatBox('Total estimé', '${_estData.reduce((a,b)=>a+b).toInt()}h', Colors.blue),
                  _buildStatBox('Total réel', '${_realData.reduce((a,b)=>a+b).toInt()}h', Colors.orange),
                  _buildStatBox('Écart', '${(_realData.reduce((a,b)=>a+b) - _estData.reduce((a,b)=>a+b)).toInt()}h', Colors.red),
                ]),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _estData.reduce((a,b)=>a+b) / _realData.reduce((a,b)=>a+b), backgroundColor: Colors.grey[300], color: Colors.blue, minHeight: 12, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                Text('Objectif atteint à ${((_estData.reduce((a,b)=>a+b) / _realData.reduce((a,b)=>a+b)) * 100).toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[600])),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ElevatedButton(onPressed: () => setState(() => _selectedPeriod = index), style: ElevatedButton.styleFrom(backgroundColor: _selectedPeriod == index ? Colors.blue : Colors.grey[200]), child: Text(label))));
  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String trend, String sub) => Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Icon(icon, size: 32, color: color), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(trend.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: trend.startsWith('+') ? Colors.green : Colors.red), const SizedBox(width: 2), Text(trend, style: TextStyle(color: trend.startsWith('+') ? Colors.green : Colors.red, fontSize: 12)), const SizedBox(width: 4), Text(sub, style: TextStyle(color: Colors.grey[500], fontSize: 10))])])));
  Widget _buildStatBox(String label, String value, Color color) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color))])));
  void _exportCSV() => _showSuccess('Export CSV effectué');
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
