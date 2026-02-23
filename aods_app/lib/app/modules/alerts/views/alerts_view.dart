import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alerts_controller.dart';
import '../../../data/models/alert_model.dart';

class AlertsView extends StatelessWidget {
  AlertsView({super.key});

  // Injecting controller when the view is created
  final AlertsController controller = Get.put(AlertsController());

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFE11D48); // rose-600
      case 'high':
        return const Color(0xFFEA580C); // orange-600
      case 'medium':
        return const Color(0xFFCA8A04); // yellow-600
      case 'low':
        return const Color(0xFF059669); // emerald-600
      default:
        return const Color(0xFF475569); // slate-600
    }
  }

  Color _getSeverityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFFFF1F2); // rose-50
      case 'high':
        return const Color(0xFFFFF7ED); // orange-50
      case 'medium':
        return const Color(0xFFFEFCE8); // yellow-50
      case 'low':
        return const Color(0xFFECFDF5); // emerald-50
      default:
        return const Color(0xFFF8FAFC); // slate-50
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'high':
        return Icons.error_outline;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF059669); // emerald-600
      case 'resolved':
        return const Color(0xFF0284C7); // sky-600
      case 'dismissed':
        return const Color(0xFFE11D48); // rose-600
      default:
        return const Color(0xFF475569); // slate-600
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFECFDF5); // emerald-50
      case 'resolved':
        return const Color(0xFFF0F9FF); // sky-50
      case 'dismissed':
        return const Color(0xFFFFF1F2); // rose-50
      default:
        return const Color(0xFFF8FAFC); // slate-50
    }
  }

  Widget _buildSeverityBadge(String severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getSeverityBgColor(severity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getSeverityColor(severity).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(severity),
            size: 12,
            color: _getSeverityColor(severity),
          ),
          const SizedBox(width: 4),
          Text(
            severity.capitalizeFirst ?? severity,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getSeverityColor(severity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusBgColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.2)),
      ),
      child: Text(
        status.capitalizeFirst ?? status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  IconData _getEventIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'user':
        return Icons.person_outline;
      case 'car':
        return Icons.directions_car_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  void _showStatusDialog(
    BuildContext context,
    AlertModel alert,
    String action,
  ) {
    final TextEditingController reasonController = TextEditingController();
    final isResolve = action == 'resolved';

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          isResolve ? 'Resolve Alert' : 'Dismiss Alert',
          style: const TextStyle(color: Color(0xFF0B63FF), fontSize: 20),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review alert details and provide a reason before continuing.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getEventIcon(alert.event.icon),
                              size: 20,
                              color: const Color(0xFF0B63FF),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.event.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  'Event',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alert.formattedId,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildSeverityBadge(alert.severity),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF0B63FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${alert.createDate} ${alert.createTime}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: Color(0xFF0B63FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alert.camera.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason *',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0B63FF)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please provide a reason.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              controller.updateAlertStatus(
                alert.id,
                action,
                reasonController.text.trim(),
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isResolve
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFFE11D48), // info or danger
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isResolve ? 'Resolve' : 'Dismiss'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSortHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Obx(
            () => DropdownButton<String>(
              value: controller.sortKey.value ?? 'timestamp',
              icon: Icon(
                controller.sortOrder.value == 'desc'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 16,
                color: const Color(0xFF0B63FF),
              ),
              underline: const SizedBox(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) controller.handleSort(newValue);
              },
              items: const [
                DropdownMenuItem(value: 'severity', child: Text('Severity')),
                DropdownMenuItem(value: 'id', child: Text('Alert ID')),
                DropdownMenuItem(value: 'timestamp', child: Text('Timestamp')),
                DropdownMenuItem(value: 'camera', child: Text('Camera')),
                DropdownMenuItem(value: 'event', child: Text('Event')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Alerts Management',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.alerts.isEmpty) {
          return const Center(child: Text('No alerts to display.'));
        }

        final pagedAlerts = controller.pagedAlerts;

        return Column(
          children: [
            _buildMobileSortHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pagedAlerts.length,
                itemBuilder: (context, index) {
                  final alert = pagedAlerts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alert.formattedId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0B63FF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSeverityBadge(alert.severity),
                                ],
                              ),
                              _buildStatusBadge(alert.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${alert.createDate} ${alert.createTime}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  alert.camera.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _getEventIcon(alert.event.icon),
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                alert.event.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (alert.status.toLowerCase() == 'active') ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showStatusDialog(
                                    context,
                                    alert,
                                    'resolved',
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF0EA5E9),
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Resolve',
                                    style: TextStyle(
                                      color: Color(0xFF0EA5E9),
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(0, 0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _showStatusDialog(
                                    context,
                                    alert,
                                    'dismissed',
                                  ),
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Dismiss',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildPaginationBar(),
          ],
        );
      }),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      // Add extra 80px bottom padding to prevent overlap with docked BottomAppBar
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12 + 80),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            int total = controller.alerts.length;
            int start =
                (controller.currentPage.value - 1) * controller.pageSize + 1;
            int end = start + controller.pageSize - 1;
            if (end > total) end = total;
            return Text(
              'Showing $start–$end of $total',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            );
          }),
          Row(
            children: [
              OutlinedButton(
                onPressed: controller.currentPage.value > 1
                    ? () =>
                          controller.goToPage(controller.currentPage.value - 1)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 0),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Previous', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  '${controller.currentPage.value} / ${controller.totalPages}',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: controller.currentPage.value < controller.totalPages
                    ? () =>
                          controller.goToPage(controller.currentPage.value + 1)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 0),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Next', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
