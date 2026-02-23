import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/alert_model.dart';

class AlertsController extends GetxController {
  final alerts = <AlertModel>[].obs;

  // Pagination
  final int pageSize = 10;
  final currentPage = 1.obs;

  // Sorting
  final sortKey = RxnString();
  final sortOrder = RxnString(); // 'asc' or 'desc'

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    alerts.value = List.generate(25, (index) {
      final i = index + 1;
      return AlertModel(
        id: i,
        severity: ['critical', 'high', 'medium', 'low'][i % 4],
        createDate: '2026-02-23',
        createTime: '10:${(i * 2).toString().padLeft(2, '0')}:00',
        alertDescription: i % 3 == 0
            ? 'Person detected in restricted area.'
            : null,
        camera: Camera(
          name: 'Camera ${i % 5 + 1}',
          location: Location(name: 'Zone ${(i % 3) + 1} North'),
        ),
        event: Event(
          name: i % 2 == 0 ? 'Person Detection' : 'Vehicle Detection',
          icon: i % 2 == 0 ? 'User' : 'Car',
        ),
        status: i % 5 == 0 ? 'resolved' : (i % 7 == 0 ? 'dismissed' : 'active'),
      );
    });
  }

  List<AlertModel> get sortedAlerts {
    List<AlertModel> data = List<AlertModel>.from(alerts);
    if (sortKey.value == null || sortOrder.value == null) return data;

    data.sort((AlertModel a, AlertModel b) {
      int comparison = 0;
      switch (sortKey.value) {
        case 'id':
          comparison = a.id.compareTo(b.id);
          break;
        case 'severity':
          comparison = a.severity.compareTo(b.severity);
          break;
        case 'timestamp':
          comparison = '${a.createDate} ${a.createTime}'.compareTo(
            '${b.createDate} ${b.createTime}',
          );
          break;
        case 'camera':
          comparison = a.camera.name.compareTo(b.camera.name);
          break;
        case 'event':
          comparison = a.event.name.compareTo(b.event.name);
          break;
        case 'location':
          comparison = a.camera.location.name.compareTo(b.camera.location.name);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
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
    currentPage.value = 1; // Reset to page 1 on sort
  }

  void updateAlertStatus(int id, String status, String reason) {
    int index = alerts.indexWhere((element) => element.id == id);
    if (index != -1) {
      alerts[index].status = status;
      alerts.refresh();

      Get.snackbar(
        'Success',
        'Alert has been $status successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(
          0xFF22C55E,
        ).withOpacity(0.9), // success color
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }
}
