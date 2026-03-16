import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';

import '../../login/controllers/login_controller.dart';
import '../../../data/models/camera_model.dart';
import '../../../data/models/event_model.dart';

class HomeController extends GetxController {
  // Navigation
  final currentIndex = 1.obs;

  // --- Create Alert Form State ---
  final cameras = <CameraModel>[].obs;
  final events = <EventModel>[].obs;

  final selectedCamera = Rxn<CameraModel>();
  final selectedEvent = Rxn<EventModel>();
  final selectedSeverity = 'high'.obs;
  final descriptionCtrl = TextEditingController();

  final selectedFile = Rxn<PlatformFile>();

  // Status flags
  final isLoadingCameras = false.obs;
  final isLoadingEvents = false.obs;
  final isUploading = false.obs;
  final isSubmitting = false.obs;

  // Messages
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Hardcoded user ID based on user request
  static const int _userId = 63;

  static const String _baseUrl = 'http://dekdee2.informatics.buu.ac.th:8066';
  late final dio.Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 600,
      ),
    );
    _initializeData();
  }

  Map<String, String> get _authHeaders {
    final token = LoginController.authToken;
    return token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {};
  }

  void _initializeData() {
    fetchCameras();
    fetchEvents();
  }

  void changePage(int index) {
    if (index >= 0 && index < 3) {
      currentIndex.value = index;
    }
  }

  Future<void> fetchCameras() async {
    isLoadingCameras.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('/api/cameras', options: dio.Options(headers: _authHeaders));
      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        if (data is Map && data['data'] != null) {
          list = data['data'];
        } else if (data is List) {
          list = data;
        }
        cameras.value = list.map((e) => CameraModel.fromJson(e)).toList();
        if (cameras.isNotEmpty) selectedCamera.value = cameras.first;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load cameras: $e';
    } finally {
      isLoadingCameras.value = false;
    }
  }

  Future<void> fetchEvents() async {
    isLoadingEvents.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('/api/events', options: dio.Options(headers: _authHeaders));
      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        if (data is Map && data['data'] != null) {
          list = data['data'];
        } else if (data is List) {
          list = data;
        }
        events.value = list.map((e) => EventModel.fromJson(e)).toList();
        if (events.isNotEmpty) selectedEvent.value = events.first;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load events: $e';
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'mp4', 'mov', 'mkv'],
        withData: true, // Needed for web
      );
      if (result != null) {
        selectedFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Error picking file: $e';
    }
  }

  void clearFile() {
    selectedFile.value = null;
  }

  void clearForm() {
    selectedSeverity.value = 'high';
    descriptionCtrl.clear();
    clearFile();
    errorMessage.value = '';
    successMessage.value = '';
    if (cameras.isNotEmpty) selectedCamera.value = cameras.first;
    if (events.isNotEmpty) selectedEvent.value = events.first;
  }

  Future<void> submitAlert() async {
    if (selectedCamera.value == null || selectedEvent.value == null) {
      errorMessage.value = 'Please select a camera and an event type.';
      return;
    }

    errorMessage.value = '';
    successMessage.value = '';
    isSubmitting.value = true;

    int? footageId;

    try {
      // Step 1 & 2: Upload file and create footage record if file exists
      if (selectedFile.value != null) {
        final file = selectedFile.value!;
        isUploading.value = true;
        
        dio.MultipartFile multipartFile;
        if (file.bytes != null) {
          // Web
          multipartFile = dio.MultipartFile.fromBytes(file.bytes!, filename: file.name);
        } else if (file.path != null) {
          // Mobile/Desktop
          multipartFile = await dio.MultipartFile.fromFile(file.path!, filename: file.name);
        } else {
          throw Exception('File data is missing');
        }

        dio.FormData formData = dio.FormData.fromMap({
          'file': multipartFile,
        });

        // 1. Upload File
        successMessage.value = 'Uploading footage...';
        final uploadRes = await _dio.post(
          '/api/files/footage',
          data: formData,
          options: dio.Options(headers: _authHeaders),
        );

        if (uploadRes.statusCode != 200 && uploadRes.statusCode != 201) {
          throw Exception(uploadRes.data['message'] ?? 'Upload failed (${uploadRes.statusCode})');
        }
        
        final uploadData = uploadRes.data;
        final uploadedPath = uploadData['path'] ?? uploadData['data']?['path'];
        if (uploadedPath == null) throw Exception('Upload succeeded but no path returned');

        // 2. Create Footage
        successMessage.value = 'Creating footage record...';
        final footageRes = await _dio.post(
          '/api/footage',
          data: {
            'camera_id': selectedCamera.value!.id,
            'path': uploadedPath,
          },
          options: dio.Options(headers: _authHeaders),
        );

        if (footageRes.statusCode != 200 && footageRes.statusCode != 201) {
          throw Exception(footageRes.data['message'] ?? 'Create footage failed (${footageRes.statusCode})');
        }

        final footageData = footageRes.data;
        footageId = footageData['footage_id'] ?? footageData['id'] ?? footageData['data']?['footage_id'] ?? footageData['data']?['id'];
        if (footageId == null) throw Exception('Create footage succeeded but no footage_id returned');
        
        isUploading.value = false;
      }

      // Step 3: Create Alert
      successMessage.value = 'Creating alert...';
      final alertPayload = {
        'user_id': _userId,
        'camera_id': selectedCamera.value!.id,
        'footage_id': footageId,
        'event_id': selectedEvent.value!.id,
        'severity': selectedSeverity.value,
        'description': descriptionCtrl.text.trim(),
      };

      final alertRes = await _dio.post(
        '/api/alerts',
        data: alertPayload,
        options: dio.Options(headers: _authHeaders),
      );

      if (alertRes.statusCode != 200 && alertRes.statusCode != 201) {
        throw Exception(alertRes.data['message'] ?? 'Create alert failed (${alertRes.statusCode})');
      }

      successMessage.value = 'Alert for "${selectedCamera.value!.name}" created successfully.';
      
      // Clear form after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        clearForm();
        // Option to swap back to Alerts tab automatically: changePage(0);
      });

    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      successMessage.value = '';
    } finally {
      isSubmitting.value = false;
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    descriptionCtrl.dispose();
    _dio.close();
    super.onClose();
  }
}
