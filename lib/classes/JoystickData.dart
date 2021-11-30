class JoystickData {
  final int joystickID; // 0 left 1 right
  final int x;
  final int y;

  JoystickData({
    required this.joystickID,
    required this.x,
    required this.y,
  });
  factory JoystickData.fromJson(Map<String, dynamic> json) {
    return JoystickData(
        joystickID: json['id'] as int,
        x: json['x'] as int,
        y: json['y'] as int);
  }
  Map<String, dynamic> toJson() => {
        'id': joystickID,
        'x': x,
        'y': y,
      };
}
