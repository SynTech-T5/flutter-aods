class Location {
  final String name;
  Location({required this.name});
}

class Camera {
  final String name;
  final Location location;
  Camera({required this.name, required this.location});
}

class Event {
  final String name;
  final String? icon;
  Event({required this.name, this.icon});
}

class AlertModel {
  final int id;
  final String severity;
  final String createDate;
  final String createTime;
  final String? alertDescription;
  final Camera camera;
  final Event event;
  String status;

  AlertModel({
    required this.id,
    required this.severity,
    required this.createDate,
    required this.createTime,
    this.alertDescription,
    required this.camera,
    required this.event,
    required this.status,
  });

  String get formattedId => 'ALR${id.toString().padLeft(3, '0')}';
}
