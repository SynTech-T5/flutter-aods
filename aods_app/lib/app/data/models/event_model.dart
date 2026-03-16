class EventModel {
  final int id;
  final String name;
  final String? icon;

  EventModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['event_id'] ?? json['id'] ?? json['evt_id'] ?? 0,
      name: json['event_name'] ?? json['name'] ?? json['evt_name'] ?? '',
      icon: json['icon_name'] ?? json['icon'] ?? json['evt_icon'],
    );
  }
}
