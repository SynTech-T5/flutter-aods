import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../data/models/alert_model.dart';
import '../../login/controllers/login_controller.dart';

class AlertsController extends GetxController {
  final alerts = <AlertModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final int pageSize = 10;
  final currentPage = 1.obs;

  // Sorting
  final sortKey = RxnString();
  final sortOrder = RxnString(); // 'asc' or 'desc'

  // ─── Dio instance ─────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://dekdee2.informatics.buu.ac.th:8066';
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
        validateStatus: (status) => status != null && status < 600,
      ),
    );
    fetchAlerts();
  }

  /// Build headers with auth token
  Map<String, String> get _authHeaders {
    final token = LoginController.authToken;
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  /// GET /api/alerts — fetch real alert data
  Future<void> fetchAlerts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _dio.get(
        '/api/alerts',
        options: Options(headers: _authHeaders),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = (data['data'] as List)
              .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
              .toList();
          alerts.value = list;
        } else {
          errorMessage.value = 'Unexpected response format';
        }
      } else {
        final data = response.data;
        String msg = 'Failed to fetch alerts (${response.statusCode})';
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
        errorMessage.value = msg;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage.value = 'Connection timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage.value = 'Cannot connect to server';
      } else {
        errorMessage.value = 'Error: ${e.message}';
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  List<AlertModel> get sortedAlerts {
    List<AlertModel> data = List<AlertModel>.from(alerts);
    if (sortKey.value == null || sortOrder.value == null) return data;

    data.sort((AlertModel a, AlertModel b) {
      int comparison = 0;
      switch (sortKey.value) {
        case 'id':
          comparison = a.alertId.compareTo(b.alertId);
          break;
        case 'severity':
          comparison = a.severity.compareTo(b.severity);
          break;
        case 'timestamp':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'camera':
          comparison = a.cameraName.compareTo(b.cameraName);
          break;
        case 'event':
          comparison = a.eventName.compareTo(b.eventName);
          break;
        case 'location':
          comparison = a.locationName.compareTo(b.locationName);
          break;
        case 'status':
          comparison = a.alertStatus.compareTo(b.alertStatus);
          break;
      }
      return sortOrder.value == 'asc' ? comparison : -comparison;
    });
    return data;
  }

  List<AlertModel> get pagedAlerts {
    int start = (currentPage.value - 1) * pageSize;
    int end = start + pageSize;
    List<AlertModel> sorted = sortedAlerts;
    if (start >= sorted.length) return [];
    if (end > sorted.length) end = sorted.length;
    return sorted.sublist(start, end);
  }

  int get totalPages {
    return (alerts.length / pageSize).ceil() == 0
        ? 1
        : (alerts.length / pageSize).ceil();
  }

  void handleSort(String key) {
    if (sortKey.value != key) {
      sortKey.value = key;
      sortOrder.value = 'asc';
    } else {
      if (sortOrder.value == 'asc') {
        sortOrder.value = 'desc';
      } else if (sortOrder.value == 'desc') {
        sortOrder.value = null;
        sortKey.value = null;
      } else {
        sortOrder.value = 'asc';
      }
    }
    currentPage.value = 1;
  }

  /// PATCH /api/alerts/:alr_id/status — resolve or dismiss an alert
  Future<void> updateAlertStatus(int alertId, String status, String reason) async {
    try {
      final response = await _dio.patch(
        '/api/alerts/$alertId/status',
        data: {
          'status': status,
          'reason': reason,
          'user_id': 63,
        },
        options: Options(headers: _authHeaders),
      );

      if (response.statusCode == 200) {
        // Update local state
        int index = alerts.indexWhere((e) => e.alertId == alertId);
        if (index != -1) {
          alerts[index].alertStatus = status;
          alerts[index].alertReason = reason;
          alerts.refresh();
        }

        Get.snackbar(
          'Success',
          'Alert has been $status successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );
      } else {
        final data = response.data;
        String msg = 'Failed to update alert (${response.statusCode})';
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── Dashboard analytics helpers ──────────────────────────────────────────

  /// Count alerts by severity
  Map<String, int> get severityCounts {
    final counts = <String, int>{};
    for (final alert in alerts) {
      final sev = alert.severity.toLowerCase();
      counts[sev] = (counts[sev] ?? 0) + 1;
    }
    return counts;
  }

  /// Count alerts by status
  Map<String, int> get statusCounts {
    final counts = <String, int>{};
    for (final alert in alerts) {
      final st = alert.alertStatus.toLowerCase();
      counts[st] = (counts[st] ?? 0) + 1;
    }
    return counts;
  }

  /// Count alerts by event name
  Map<String, int> get eventCounts {
    final counts = <String, int>{};
    for (final alert in alerts) {
      counts[alert.eventName] = (counts[alert.eventName] ?? 0) + 1;
    }
    return counts;
  }

  /// Count alerts by event name grouped by severity (for stacked bar chart)
  /// Returns Map<eventName, Map<severity, count>>
  Map<String, Map<String, int>> get eventCountsBySeverity {
    final result = <String, Map<String, int>>{};
    for (final alert in alerts) {
      final event = alert.eventName;
      final severity = alert.severity.toLowerCase();
      result.putIfAbsent(event, () => <String, int>{});
      result[event]![severity] = (result[event]![severity] ?? 0) + 1;
    }
    return result;
  }

  /// Group alerts by hour for line chart (last 24h)
  Map<int, int> get alertsByHour {
    final counts = <int, int>{};
    for (int i = 0; i < 24; i++) {
      counts[i] = 0;
    }
    for (final alert in alerts) {
      try {
        final dt = DateTime.parse(alert.createdAt).toLocal();
        counts[dt.hour] = (counts[dt.hour] ?? 0) + 1;
      } catch (_) {}
    }
    return counts;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
