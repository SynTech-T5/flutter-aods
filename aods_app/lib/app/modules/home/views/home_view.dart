import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../alerts/views/alerts_view.dart';
import '../../login/controllers/login_controller.dart';
import 'dashboard_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens for the bottom navigation: Alert, Home, Dashboard
    final List<Widget> screens = [
      AlertsView(), // 0: Alert
      const _HomeContentView(), // 1: Home (center)
      const DashboardView(), // 2: Dashboard
    ];

    return Scaffold(
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() {
        final int currentIndex = controller.currentIndex.value;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Alert',
                    isSelected: currentIndex == 0,
                    onTap: () => controller.changePage(0),
                  ),
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    isSelected: currentIndex == 1,
                    onTap: () => controller.changePage(1),
                  ),
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isSelected: currentIndex == 2,
                    onTap: () => controller.changePage(2),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? const Color(0xFF0077FF)
        : const Color(0xFFBFBFBF);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                height: 3,
                width: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0077FF),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 4),
              )
            else
              const SizedBox(height: 7),
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home content view (center tab) - Create Alert Form
class _HomeContentView extends StatelessWidget {
  const _HomeContentView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFECF8FF),
      appBar: AppBar(
        title: const Text(
          'Create Alert',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF3B82F6)),
            tooltip: 'Logout',
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Color(0xFF023D8B)),
                  ),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFFBFBFBF))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final loginCtrl = Get.put(LoginController());
                        loginCtrl.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D2D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCameras.value || controller.isLoadingEvents.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0077FF)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alert Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF023D8B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill in alert details below and press Create Alert.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                ),
                const SizedBox(height: 24),

                // Camera Row
                _buildLabel('Camera Name', required: true),
                const SizedBox(height: 4),
                _buildCameraDropdown(controller),
                const SizedBox(height: 16),

                // Severity Row
                _buildLabel('Severity', required: true),
                const SizedBox(height: 4),
                _buildSeverityDropdown(controller),
                const SizedBox(height: 16),

                // Event Row
                _buildLabel('Event Type', required: true),
                const SizedBox(height: 4),
                _buildEventDropdown(controller),
                const SizedBox(height: 16),

                // Description
                _buildLabel('Description'),
                const SizedBox(height: 4),
                TextField(
                  controller: controller.descriptionCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your description',
                    hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0077FF), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // File Upload
                _buildLabel('Upload Footage'),
                const SizedBox(height: 4),
                _buildFileUpload(controller),
                const SizedBox(height: 24),

                // Status Message
                if (controller.errorMessage.value.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2D3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF2D2D).withOpacity(0.3)),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Color(0xFFFF2D2D), fontSize: 13),
                    ),
                  ),
                if (controller.successMessage.value.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFFFC3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3BCF00).withOpacity(0.3)),
                    ),
                    child: Text(
                      controller.successMessage.value,
                      style: const TextStyle(color: Color(0xFF3BCF00), fontSize: 13),
                    ),
                  ),
                if (controller.errorMessage.value.isNotEmpty || controller.successMessage.value.isNotEmpty)
                  const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : controller.submitAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Create Alert',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF023D8B),
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFFF2D2D)),
                )
              ]
            : [],
      ),
    );
  }

  Widget _buildCameraDropdown(HomeController controller) {
    if (controller.cameras.isEmpty) {
      return const Text('No cameras available', style: TextStyle(color: Color(0xFFBFBFBF)));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: controller.selectedCamera.value?.id,
          hint: const Text('Select Camera', style: TextStyle(fontSize: 13, color: Color(0xFFBFBFBF))),
          items: controller.cameras.map((cam) {
            return DropdownMenuItem<int>(
              value: cam.id,
              child: Text(
                '${cam.name} (${cam.locationName.isNotEmpty ? cam.locationName : 'No Location'})',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedCamera.value = controller.cameras.firstWhere((c) => c.id == val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSeverityDropdown(HomeController controller) {
    final severities = [
      {'value': 'low', 'label': 'Low', 'color': const Color(0xFF3BCF00)},
      {'value': 'medium', 'label': 'Medium', 'color': const Color(0xFFFFCC00)},
      {'value': 'high', 'label': 'High', 'color': const Color(0xFFFF5900)},
      {'value': 'critical', 'label': 'Critical', 'color': const Color(0xFFFF2D2D)},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedSeverity.value,
          items: severities.map((sev) {
            return DropdownMenuItem<String>(
              value: sev['value'] as String,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: sev['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sev['label'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) controller.selectedSeverity.value = val;
          },
        ),
      ),
    );
  }

  Widget _buildEventDropdown(HomeController controller) {
    if (controller.events.isEmpty) {
      return const Text('No events available', style: TextStyle(color: Color(0xFFBFBFBF)));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: controller.selectedEvent.value?.id,
          hint: const Text('Select Event', style: TextStyle(fontSize: 13, color: Color(0xFFBFBFBF))),
          items: controller.events.map((evt) {
            return DropdownMenuItem<int>(
              value: evt.id,
              child: Text(
                evt.name,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedEvent.value = controller.events.firstWhere((e) => e.id == val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFileUpload(HomeController controller) {
    final file = controller.selectedFile.value;

    return GestureDetector(
      onTap: controller.isSubmitting.value ? null : controller.pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: file == null
            ? const Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: Color(0xFF0077FF), size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Tap to upload footage',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0077FF), fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Max 10MB (Images, MP4, MOV)',
                    style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF0077FF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFFFF2D2D)),
                    onPressed: controller.clearFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
      ),
    );
  }
}

