class CameraModel {
  final int id;
  final String name;
  final String locationName;

  CameraModel({
    required this.id,
    required this.name,
    required this.locationName,
  });

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      id: json['camera_id'] ?? json['id'] ?? 0,
      name: json['camera_name'] ?? json['name'] ?? '',
      locationName: json['location_name'] ?? (json['location'] != null ? json['location']['name'] : '') ?? '',
    );
  }
}
