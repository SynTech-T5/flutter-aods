import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/landing_controller.dart';
import '../../../routes/app_pages.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F7FF), Color(0xFFF6FAFF), Color(0xFFEEF2FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNav(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'AI-Powered CCTV',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB), // text-blue-600
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Automate Object\nDetection System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Color(0xFF0F172A), // text-slate-900
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Real-time alerts, camera management, and clean analytics — all in one sleek dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569), // text-slate-600
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        height: 1,
                        width: 100,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFCBD5E1), // slate-300
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildFeatures(),
                      const SizedBox(height: 40),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/automate-object-detection-system-icon.png',
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B63FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Automate ',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                      ), // secondary color
                    ),
                    TextSpan(
                      text: 'Object Detection System',
                      style: TextStyle(
                        color: Color(0xFF0B63FF),
                      ), // primary color
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.LOGIN);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B63FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Real-time Alerts',
          desc:
              'Instant notifications with clear severity to keep you ahead of incidents.',
          icon: Icons.notifications_active_outlined,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          title: 'Camera Management',
          desc:
              'Organize cameras, statuses, and health in a streamlined interface.',
          icon: Icons.video_camera_back_outlined,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          title: 'Analytics & Trends',
          desc: 'Clean charts for daily activity and severity breakdowns.',
          icon: Icons.analytics_outlined,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withOpacity(0.7),
        ), // slate-200
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDBEAFE),
                width: 2,
              ), // blue-100
            ),
            child: Icon(icon, color: const Color(0xFF0B63FF), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final year = DateTime.now().year;
    return Column(
      children: [
        Text(
          '© $year Automate Object Detection System',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xCC64748B), // slate-500/80
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SynTech-T5 x TTT Brother',
          style: TextStyle(fontSize: 11, color: Color(0xCC64748B)),
        ),
      ],
    );
  }
}
