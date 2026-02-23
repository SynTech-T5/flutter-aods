import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // ─── Form controllers ───────────────────────────────────────────────────────
  final usernameOrEmailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // ─── Reactive state ─────────────────────────────────────────────────────────
  final isPasswordVisible = false.obs;
  final isRememberMe = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ─── Server URL ─────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://dekdee2.informatics.buu.ac.th:8066';

  // ─── Dio instance ────────────────────────────────────────────────────────────
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // ให้ Dio ไม่ throw exception เมื่อ status >= 400
        // เพื่อให้เราจัดการ error message เองได้
        validateStatus: (status) => status != null && status < 600,
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleRememberMe() => isRememberMe.toggle();

  /// POST /api/auth/login
  Future<void> login() async {
    final username = usernameOrEmailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'กรุณากรอก Username/Email และ Password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'usernameOrEmail': username,
          'password': password,
          'remember': isRememberMe.value,
        },
      );

      if (response.statusCode == 200) {
        // Login สำเร็จ → ไปหน้า home
        Get.offAllNamed(Routes.HOME);
      } else {
        // ดึง error message จาก response body
        final data = response.data;
        String msg = 'Login failed (${response.statusCode})';
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
        errorMessage.value = msg;
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage.value = 'Connection timeout — กรุณาตรวจสอบการเชื่อมต่อ';
          break;
        case DioExceptionType.connectionError:
          errorMessage.value =
              'ไม่สามารถเชื่อมต่อ server ได้\n'
              'ถ้าใช้ Chrome: รันด้วย\n--disable-web-security\nหรือให้ backend เพิ่ม CORS header';
          break;
        case DioExceptionType.badResponse:
          final data = e.response?.data;
          String msg = 'Login failed (${e.response?.statusCode})';
          if (data is Map && data['message'] != null) {
            msg = data['message'].toString();
          }
          errorMessage.value = msg;
          break;
        default:
          errorMessage.value = 'เกิดข้อผิดพลาด: ${e.message}';
      }
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาดที่ไม่คาดคิด: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameOrEmailCtrl.dispose();
    passwordCtrl.dispose();
    _dio.close();
    super.onClose();
  }
}
