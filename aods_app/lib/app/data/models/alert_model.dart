class AlertModel {
  final int alertId;
  final String severity;
  final String createdAt; // ISO 8601
  final int cameraId;
  final String cameraName;
  final String? eventIcon;
  final String eventName;
  final String locationName;
  String alertStatus;
  final String? alertDescription;
  String? alertReason;
  final int? footageId;
  final String? footagePath;
  final String? createdBy;

  AlertModel({
    required this.alertId,
    required this.severity,
    required this.createdAt,
    required this.cameraId,
    required this.cameraName,
    this.eventIcon,
    required this.eventName,
    required this.locationName,
    required this.alertStatus,
    this.alertDescription,
    this.alertReason,
    this.footageId,
    this.footagePath,
    this.createdBy,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alert_id'] as int,
      severity: json['severity'] as String? ?? 'low',
      createdAt: json['created_at'] as String? ?? '',
      cameraId: json['camera_id'] as int? ?? 0,
      cameraName: json['camera_name'] as String? ?? '',
      eventIcon: json['event_icon'] as String?,
      eventName: json['event_name'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      alertStatus: json['alert_status'] as String? ?? 'active',
      alertDescription: json['alert_description'] as String?,
      alertReason: json['alert_reason'] as String?,
      footageId: json['footage_id'] as int?,
      footagePath: json['footage_path'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  String get formattedId => 'ALR${alertId.toString().padLeft(3, '0')}';

  /// Parse ISO 8601 created_at into a readable date string
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  /// Parse ISO 8601 created_at into a readable time string
  String get formattedTime {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
