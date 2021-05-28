import 'dart:convert';

class Chandler {
  final double latitude;
  final double longitude;
  DateTime createdAt;
  Chandler({
    required this.createdAt,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Chandler.fromMap(Map<String, dynamic> map) {
    return Chandler(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chandler.fromJson(String source) =>
      Chandler.fromMap(json.decode(source));

  Chandler copyWith({
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Chandler(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Chandler(latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chandler &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ createdAt.hashCode;
}
