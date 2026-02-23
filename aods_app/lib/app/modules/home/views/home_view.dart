import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../alerts/views/alerts_view.dart';
import 'dashboard_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens for the bottom navigation
    final List<Widget> screens = [
      AlertsView(), // 0: Alerts / Home
      const Center(
        child: Text('Market', style: TextStyle(fontSize: 24)),
      ), // 1: Market
      const Center(
        child: Text('Assets', style: TextStyle(fontSize: 24)),
      ), // 2: Assets
      const DashboardView(), // 3: Menu / Dashboard
    ];

    return Scaffold(
      extendBody: true, // required to show background behind bottom app bar
      body: Obx(() => screens[controller.currentIndex.value]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the center refresh button
        },
        backgroundColor: const Color(0xFF3B82F6), // blue-500
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.sync, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Obx(() {
        final int currentIndex = controller.currentIndex.value;
        return BottomAppBar(
          elevation: 10,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => controller.changePage(0),
                ),
                _buildNavItem(
                  icon: Icons.show_chart_outlined,
                  label: 'Market',
                  isSelected: currentIndex == 1,
                  onTap: () => controller.changePage(1),
                ),
                const SizedBox(
                  width: 48,
                ), // Space for the floating action button
                _buildNavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Assets',
                  isSelected: currentIndex == 2,
                  onTap: () => controller.changePage(2),
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Menu',
                  isSelected: currentIndex == 3,
                  onTap: () => controller.changePage(3),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected
        ? const Color(0xFF3B82F6)
        : const Color(0xFF94A3B8); // blue-500 / slate-400

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
                height: 2,
                width: 24,
                color: const Color(0xFF3B82F6),
                margin: const EdgeInsets.only(bottom: 6),
              )
            else
              const SizedBox(height: 8),
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
