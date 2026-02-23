import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // ─── Brand colors ────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF0B63FF);
  static const Color _secondary = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0F7FF),
                  Color(0xFFF6FAFF),
                  Color(0xFFEEF2FF),
                ],
              ),
            ),
          ),

          // ── Blue spotlight blobs ────────────────────────────────────────────
          _GlowBlob(
            color: const Color(0x55BFDBFE),
            size: 380,
            top: -120,
            left: -120,
          ),
          _GlowBlob(
            color: const Color(0x4D6366F1),
            size: 420,
            bottom: -160,
            right: -120,
          ),

          // ── Centered scrollable card ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: _buildCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Glass Card ──────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xD1FFFFFF), // white ~82% opacity
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x99D1E3FF), // ~60% opacity
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4093C5FD), // ~25% opacity
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logo + Brand ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon badge
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.videocam_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _secondary,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Object Detection System',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _primary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Form section ─────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Username / Email ──
        _Label('Username or Email'),
        const SizedBox(height: 6),
        _AppTextField(
          controller: controller.usernameOrEmailCtrl,
          hint: 'Enter your email or username',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),

        // ── Password ──
        _Label('Password'),
        const SizedBox(height: 6),
        Obx(() {
          final isVisible = controller.isPasswordVisible.value;
          return _AppTextField(
            controller: controller.passwordCtrl,
            hint: 'Enter your password',
            obscureText: !isVisible,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.login(),
            suffixIcon: GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),

        // ── Remember me + Forgot password ──
        _buildRememberRow(),
        const SizedBox(height: 16),

        // ── Error message ──
        Obx(() {
          final msg = controller.errorMessage.value;
          if (msg.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              msg,
              style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
            ),
          );
        }),

        // ── Login button ──
        _buildLoginButton(),
      ],
    );
  }

  // ─── Remember + Forgot row ────────────────────────────────────────────────────
  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Custom animated checkbox
        GestureDetector(
          onTap: controller.toggleRememberMe,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Obx(() {
                final checked = controller.isRememberMe.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checked ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _primary, width: 1.5),
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                );
              }),
              const SizedBox(width: 8),
              const Text(
                'Remember me',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),

        // Forgot password link
        GestureDetector(
          onTap: () => Get.snackbar(
            'Coming soon',
            'Forgot password feature is not yet available',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            colorText: const Color(0xFF334155),
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Login button ──────────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Obx(() {
      final loading = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: loading ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: const Color(
              0x8C0B63FF,
            ), // _primary ~55% opacity
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      );
    });
  }
}

// ─── Private helper widgets ───────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        color: Color(0xFF334155),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: Color(0xFFCBD5E1),
        ),
        filled: true,
        fillColor: const Color(0xEBFFFFFF), // white ~92% opacity
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0B63FF), width: 1.5),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}

/// Blurred glow blob positioned absolutely
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;

  const _GlowBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
