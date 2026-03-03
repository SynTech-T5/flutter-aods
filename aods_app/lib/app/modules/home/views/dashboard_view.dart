import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../alerts/controllers/alerts_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the shared AlertsController
    final AlertsController alertsCtrl = Get.put(AlertsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Dashboard Analytics',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: () => alertsCtrl.fetchAlerts(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (alertsCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
          );
        }

        if (alertsCtrl.alerts.isEmpty) {
          return const Center(
            child: Text(
              'No alert data available for dashboard.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          );
        }

        final severityCounts = alertsCtrl.severityCounts;
        final statusCounts = alertsCtrl.statusCounts;
        final eventCounts = alertsCtrl.eventCounts;
        final alertsByHour = alertsCtrl.alertsByHour;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              _buildSummaryCards(alertsCtrl.alerts.length, statusCounts),
              const SizedBox(height: 24),

              // Alerts Over Time
              const Text(
                'Alerts Over Time (by hour)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              _buildLineChartCard(alertsByHour),
              const SizedBox(height: 24),

              // Events by Type (bar chart)
              const Text(
                'Events by Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              _buildEventBarChartCard(eventCounts),
              const SizedBox(height: 24),

              // Severity Distribution (pie-like horizontal bars)
              const Text(
                'Severity Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              _buildSeverityCard(severityCounts, alertsCtrl.alerts.length),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(int totalAlerts, Map<String, int> statusCounts) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Alerts',
            totalAlerts.toString(),
            Icons.notifications_active,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            (statusCounts['active'] ?? 0).toString(),
            Icons.warning_amber_rounded,
            const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Resolved',
            (statusCounts['resolved'] ?? 0).toString(),
            Icons.check_circle_outline,
            const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(Map<int, int> alertsByHour) {
    // Find max Y for scaling
    final maxCount = alertsByHour.values.fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxCount + 2).toDouble();

    // Create spots from real data
    final spots = <FlSpot>[];
    for (int h = 0; h < 24; h++) {
      spots.add(FlSpot(h.toDouble(), (alertsByHour[h] ?? 0).toDouble()));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}:00',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3B82F6).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBarChartCard(Map<String, int> eventCounts) {
    final entries = eventCounts.entries.toList();
    if (entries.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No event data')),
      );
    }

    final maxCount = entries.fold<int>(0, (a, b) => a > b.value ? a : b.value);
    final maxY = (maxCount + 2).toDouble();

    final colors = [
      const Color(0xFF3B82F6), // blue
      const Color(0xFF8B5CF6), // violet
      const Color(0xFFEC4899), // pink
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF59E0B), // amber
      const Color(0xFFEF4444), // red
      const Color(0xFF22C55E), // green
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[group.x.toInt()].key}\n${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[idx].key,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: data.value.toDouble(),
                  width: 24,
                  borderRadius: BorderRadius.circular(6),
                  color: colors[idx % colors.length],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSeverityCard(Map<String, int> severityCounts, int total) {
    final severities = [
      {'key': 'critical', 'label': 'Critical', 'color': const Color(0xFFE11D48)},
      {'key': 'high', 'label': 'High', 'color': const Color(0xFFEA580C)},
      {'key': 'medium', 'label': 'Medium', 'color': const Color(0xFFCA8A04)},
      {'key': 'low', 'label': 'Low', 'color': const Color(0xFF059669)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: severities.map((sev) {
          final count = severityCounts[sev['key'] as String] ?? 0;
          final ratio = total > 0 ? count / total : 0.0;
          final color = sev['color'] as Color;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    sev['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 12,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: Text(
                    count.toString(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
