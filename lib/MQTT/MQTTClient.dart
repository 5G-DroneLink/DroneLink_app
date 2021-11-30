import 'package:DroneLink/MQTT/states/MQTTState.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClient {
  String _id, _host, topicDown;
  MQTTState _state;
  late MqttServerClient _client;

  MQTTClient(this._host, this._id, this.topicDown, this._state);

  void init() {
    _client = MqttServerClient(_host, _id);
    _client.port = 1883;
    _client.logging(on: true);
    _client.keepAlivePeriod = 20;

    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;

    final connectMsg = MqttConnectMessage()
        .withClientIdentifier(_id)
        .withWillTopic("willTopic")
        .withWillMessage("willMessage")
        .startClean();
    print("> MQTT Client: connecting...");
  }

  void connect() async {
    try {
      print("> MQTT Client: connecting...");
      _state.setConnectionState(MQTTConnectionState.connecting);
      await _client.connect();
    } on Exception catch (e) {
      print("> MQTT Client: EXCEPTION CATCH!!: $e");
      disconnect();
    }
  }

  void disconnect() {
    print("> MQTT Client: disconnecting ...");
    _client.disconnect();
  }

  void publish(
    String topic,
    String msg,
  ) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    print("> MQTT Client: Subscribed to $topic");
  }

  void onDisconnected() {
    print("> MQTT Client: Disconnected");
    _state.setConnectionState(MQTTConnectionState.disconnected);
  }

  void onConnected() {
    _state.setConnectionState(MQTTConnectionState.connected);
    print("[MQTT] Client connected ...");
    _client.subscribe(topicDown, MqttQos.exactlyOnce);
    //_client.subscribe(topicUp, MqttQos.exactlyOnce);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      _state.setReceivedMsg(payload);
      print("> MQTT Client: received Message: $payload ${c[0].topic}>");
    });
  }
}
