import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../alerts/controllers/alerts_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // ─── Color palette ────────────────────────────────────────────────────
  static const Color colorPrimary = Color(0xFF0077FF);
  static const Color colorPrimaryBg = Color(0xFFCEE5FF);
  static const Color colorSecondary = Color(0xFF023D8B);
  static const Color colorSuccess = Color(0xFF3BCF00);
  static const Color colorSuccessBg = Color(0xFFDFFFC3);
  static const Color colorDanger = Color(0xFFFF2D2D);
  static const Color colorDangerBg = Color(0xFFFFE2D3);
  static const Color colorWarning = Color(0xFFFFCC00);
  static const Color colorWarningBg = Color(0xFFFFFAE5);
  static const Color colorOrange = Color(0xFFFF5900);
  static const Color colorOrangeBg = Color(0xFFFFE2D3);
  static const Color colorPurple = Color(0xFFEA00FF);
  static const Color colorPurpleBg = Color(0xFFFDE6FF);
  static const Color colorBg = Color(0xFFECF8FF);
  static const Color colorGray = Color(0xFFBFBFBF);
  static const Color colorSoftGray = Color(0xFFE8E8E8);
  static const Color colorHardGray = Color(0xFFAAAAAA);

  // Severity colors (for stacked chart)
  static const Map<String, Color> severityColors = {
    'critical': colorDanger,
    'high': colorOrange,
    'medium': colorWarning,
    'low': colorSuccess,
  };
  static const Map<String, Color> severityBgColors = {
    'critical': colorDangerBg,
    'high': colorOrangeBg,
    'medium': colorWarningBg,
    'low': colorSuccessBg,
  };
  static const List<String> severityOrder = ['critical', 'high', 'medium', 'low'];

  @override
  Widget build(BuildContext context) {
    final AlertsController alertsCtrl = Get.put(AlertsController());

    return Scaffold(
      backgroundColor: colorBg,
      appBar: AppBar(
        title: const Text(
          'Dashboard Analytics',
          style: TextStyle(
            color: Color(0xFF000000),
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
            icon: const Icon(Icons.refresh, color: colorPrimary),
            onPressed: () => alertsCtrl.fetchAlerts(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (alertsCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: colorPrimary),
          );
        }

        if (alertsCtrl.alerts.isEmpty) {
          return const Center(
            child: Text(
              'No alert data available for dashboard.',
              style: TextStyle(color: colorHardGray),
            ),
          );
        }

        final severityCounts = alertsCtrl.severityCounts;
        final statusCounts = alertsCtrl.statusCounts;
        final eventCountsBySeverity = alertsCtrl.eventCountsBySeverity;
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
                  color: colorSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildLineChartCard(context, alertsByHour),
              const SizedBox(height: 24),

              // Events by Type (stacked bar chart)
              const Text(
                'Events by Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStackedBarChartCard(context, eventCountsBySeverity),
              const SizedBox(height: 24),

              // Severity Distribution
              const Text(
                'Severity Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorSecondary,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                totalAlerts.toString(),
                Icons.notifications_active,
                colorPrimary,
                isNarrow,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Active',
                (statusCounts['active'] ?? 0).toString(),
                Icons.warning_amber_rounded,
                colorDanger,
                isNarrow,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Resolved',
                (statusCounts['resolved'] ?? 0).toString(),
                Icons.check_circle_outline,
                colorSuccess,
                isNarrow,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isNarrow,
  ) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 10 : 14),
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
          Icon(icon, color: color, size: isNarrow ? 22 : 28),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isNarrow ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isNarrow ? 10 : 12,
              color: colorHardGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(BuildContext context, Map<int, int> alertsByHour) {
    final maxCount = alertsByHour.values.fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxCount + 2).toDouble();
    final spots = <FlSpot>[];
    for (int h = 0; h < 24; h++) {
      spots.add(FlSpot(h.toDouble(), (alertsByHour[h] ?? 0).toDouble()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final labelInterval = isNarrow ? 6.0 : 4.0;

        return Container(
          height: isNarrow ? 220 : 280,
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 8 : 16,
            16,
            isNarrow ? 8 : 16,
            isNarrow ? 8 : 16,
          ),
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
                    FlLine(color: colorSoftGray, strokeWidth: 1),
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
                    reservedSize: 28,
                    interval: labelInterval,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          '${value.toInt()}:00',
                          style: TextStyle(
                            color: colorHardGray,
                            fontSize: isNarrow ? 9 : 11,
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
                    reservedSize: isNarrow ? 30 : 36,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: colorHardGray,
                          fontSize: isNarrow ? 10 : 11,
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
                  color: colorPrimary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: !isNarrow,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorPrimary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Stacked bar chart: events by type, stacked by severity
  Widget _buildStackedBarChartCard(
    BuildContext context,
    Map<String, Map<String, int>> eventCountsBySeverity,
  ) {
    final eventNames = eventCountsBySeverity.keys.toList();
    if (eventNames.isEmpty) {
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

    // Calculate max stacked height
    double maxY = 0;
    for (final entry in eventCountsBySeverity.values) {
      double total = 0;
      for (final count in entry.values) {
        total += count;
      }
      if (total > maxY) maxY = total;
    }
    maxY = maxY + 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final barWidth = isNarrow ? 16.0 : 22.0;

        return Column(
          children: [
            Container(
              height: isNarrow ? 240 : 300,
              padding: EdgeInsets.fromLTRB(
                isNarrow ? 8 : 16,
                16,
                isNarrow ? 8 : 16,
                isNarrow ? 8 : 16,
              ),
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
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final eventName = eventNames[group.x.toInt()];
                        final sevData = eventCountsBySeverity[eventName] ?? {};
                        final lines = <String>[];
                        lines.add(eventName);
                        for (final sev in severityOrder) {
                          final count = sevData[sev] ?? 0;
                          if (count > 0) {
                            lines.add('${sev.capitalizeFirst}: $count');
                          }
                        }
                        return BarTooltipItem(
                          lines.join('\n'),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
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
                        reservedSize: isNarrow ? 50 : 44,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= eventNames.length) {
                            return const SizedBox();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            angle: isNarrow ? -0.5 : -0.3,
                            child: Text(
                              eventNames[idx].length > 10
                                  ? '${eventNames[idx].substring(0, 9)}…'
                                  : eventNames[idx],
                              style: TextStyle(
                                color: colorHardGray,
                                fontSize: isNarrow ? 9 : 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isNarrow ? 28 : 36,
                        interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: colorHardGray,
                              fontSize: isNarrow ? 10 : 11,
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
                        FlLine(color: colorSoftGray, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: eventNames.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final eventName = entry.value;
                    final sevData = eventCountsBySeverity[eventName] ?? {};

                    // Build stacked rod segments: critical at bottom → low at top
                    final rodStackItems = <BarChartRodStackItem>[];
                    double cumulative = 0;
                    for (final sev in severityOrder) {
                      final count = (sevData[sev] ?? 0).toDouble();
                      if (count > 0) {
                        rodStackItems.add(BarChartRodStackItem(
                          cumulative,
                          cumulative + count,
                          severityColors[sev]!,
                        ));
                        cumulative += count;
                      }
                    }

                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: cumulative,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: rodStackItems,
                          color: Colors.transparent,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: severityOrder.map((sev) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: severityColors[sev],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sev.capitalizeFirst ?? sev,
                        style: const TextStyle(
                          fontSize: 11,
                          color: colorHardGray,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeverityCard(Map<String, int> severityCounts, int total) {
    final severities = [
      {'key': 'critical', 'label': 'Critical', 'color': colorDanger},
      {'key': 'high', 'label': 'High', 'color': colorOrange},
      {'key': 'medium', 'label': 'Medium', 'color': colorWarning},
      {'key': 'low', 'label': 'Low', 'color': colorSuccess},
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
                  width: 66,
                  child: Text(
                    sev['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    count.toString(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorSecondary,
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
