class ControlData {
  final int ID; // 0 Joystick left 1 Joystick right 2 Arm 3 Disarm 4 RTH
  final int
      p1; // if ID equals either 0 or 1 (joysticks) X otherwise it is ignored
  final int
      p2; // if ID equals either 0 or 1 (joysticks) Y otherwise it is ignored

  ControlData({
    required this.ID,
    required this.p1,
    required this.p2,
  });
  factory ControlData.fromJson(Map<String, dynamic> json) {
    return ControlData(
        ID: json['id'] as int, p1: json['p1'] as int, p2: json['p2'] as int);
  }
  Map<String, dynamic> toJson() => {
        'id': ID,
        'p1': p1,
        'p2': p2,
      };
}
