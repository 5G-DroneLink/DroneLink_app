class Telemetry {
  final double pitch;
  final double roll;
  final double altitude;
  final double speed;
  final double latitude;
  final double longitude;

  Telemetry(
      {required this.pitch,
      required this.roll,
      required this.altitude,
      required this.speed,
      required this.latitude,
      required this.longitude});

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
        pitch: json["pitch"] as double,
        roll: json["roll"] as double,
        altitude: json["altitude"] as double,
        speed: json["speed"] as double,
        latitude: json["latitude"] as double,
        longitude: json["longitude"] as double);
  }
  Map<String, dynamic> toJson() => {
        'pitch': pitch,
        'roll': roll,
        'altitude': altitude,
        'speed': speed,
        'latitude': latitude,
        'longitude': longitude
      };
}
