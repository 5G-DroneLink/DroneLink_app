class Telemetry {
  final double pitch;
  final double roll;
  final double yaw;
  final double altitude;
  final double speed;
  final double latitude;
  final double longitude;

  Telemetry(
      {required this.pitch,
      required this.roll,
      required this.yaw,
      required this.altitude,
      required this.speed,
      required this.latitude,
      required this.longitude});

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
        pitch: (json["pitch"]).toDouble(),
        roll: (json["roll"]).toDouble(),
        yaw: (json["yaw"]).toDouble(),
        altitude: (json["altitude"]).toDouble(),
        speed: (json["speed"]).toDouble(),
        latitude: (json["latitude"]).toDouble(),
        longitude: (json["longitude"]).toDouble());
  }
  Map<String, dynamic> toJson() => {
        'pitch': pitch,
        'roll': roll,
        'yaw': yaw,
        'altitude': altitude,
        'speed': speed,
        'latitude': latitude,
        'longitude': longitude
      };
}
