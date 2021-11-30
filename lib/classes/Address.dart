class Address {
  final String host;
  final String ip;
  final int port;
  final String token;

  Address(
      {required this.host,
      required this.ip,
      required this.port,
      required this.token});
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        host: json["host"] as String,
        ip: json['ip'] as String,
        port: json['port'] as int,
        token: json['token'] as String);
  }
  Map<String, dynamic> toJson() => {
        'host': host,
        'ip': ip,
        'port': port,
        'token': token,
      };
}
