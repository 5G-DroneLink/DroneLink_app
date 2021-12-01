import 'dart:convert';
import 'dart:math';

import 'package:DroneLink/MQTT/MQTTClient.dart';
import 'package:DroneLink/MQTT/states/MQTTState.dart';
import 'package:DroneLink/classes/Address.dart';
import 'package:DroneLink/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:DroneLink/classes/ControlData.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../classes/telemetry.dart';

class Home extends StatefulWidget {
  const Home({key, this.scanResult}) : super(key: key);
  static const String routeName = '/home';
  final String? scanResult;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MQTTState _mqttState;
  late MQTTClient _client;
  late Address address;
  late IO.Socket socket;
  late IO.Socket telemetrySocket;
  static const String mqttServerIP = "172.16.5.44";
  Telemetry telemetry = Telemetry(
      pitch: 0,
      roll: 0,
      speed: 0,
      altitude: 0,
      longitude: 0,
      latitude: 0,
      yaw: 0);
  bool _isConnectedTelemetry = false;
  int prevThr = 0;
  int prevYaw = 0;
  int prevPth = 0;
  int prevRoll = 0;
  static const String videoUri = "rtsp://172.16.5.44:8554/unicast";
  bool _isOverlayActive = true;
  final VlcPlayerController _vlcViewController = VlcPlayerController.network(
    videoUri,
    hwAcc: HwAcc.FULL,
    autoPlay: true,
    options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(0)])),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _initMQTT());
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _initDronelinkDesktopComm());
  }

  @override
  Widget build(BuildContext context) {
    _mqttState = Provider.of<MQTTState>(context);
    //_updateTelemetry(_mqttState.getReceivedMsg);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(drawer: drawer(context), body: _realTimeControl(context));
  }

  Widget _realTimeControl(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Center(
              child: VlcPlayer(
            controller: _vlcViewController,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          )),
          Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      child: Joystick(
                        mode: JoystickMode.all,
                        period: const Duration(milliseconds: 200),
                        listener: (details) {
                          int id, x, y;
                          id = 0;
                          x = (((details.x) + 1) * 500 + 1000)
                              .toInt(); // 1000 0(down) 1500 0.5(center) 2000 1(up)
                          y = ((((details.y) * -1) + 1) * 500 + 1000)
                              .toInt(); // 1000 0(left) 1500 0.5(center) 2000 1(right)
                          ControlData data = ControlData(ID: id, p1: x, p2: y);
                          if (sqrt((pow((x - prevYaw), 2) +
                                  pow((y - prevThr), 2))) >
                              (60)) {
                            //Only send if it's at least  a 3%(3*2000/100) of the maximum distance of the previous sample
                            _client.publish(
                                "Dronelink/left", jsonEncode(data.toJson()));
                            setState(() {
                              print("Izq: x " +
                                  x.toString() +
                                  " y " +
                                  y.toString());
                            });
                          }
                          prevYaw = x;
                          prevThr = y;
                        },
                      ),
                      visible: _isOverlayActive,
                    ),
                    Row(
                      children: [_disableOverlay(context)],
                    ),
                  ],
                ),
                Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Joystick(
                        mode: JoystickMode.all,
                        period: const Duration(milliseconds: 200),
                        listener: (details) {
                          int id, x, y;
                          id = 1;
                          x = (((details.x) + 1) * 500 + 1000)
                              .toInt(); // 1000 0(down) 1500 0.5(center) 2000 1(up)
                          y = ((((details.y) * -1) + 1) * 500 + 1000)
                              .toInt(); // 1000 0(left) 1500 0.5(center) 2000 1(right)
                          ControlData data = ControlData(ID: id, p1: x, p2: y);
                          if (sqrt((pow((x - prevRoll), 2) +
                                  pow((y - prevPth), 2))) >
                              (60)) {
                            ////Only send if it's at least  a 3%(3*2000/100) of the maximum distance of the previous sample
                            _client.publish(
                                "Dronelink/right", jsonEncode(data.toJson()));
                            setState(() {
                              print("Der: x " +
                                  x.toString() +
                                  " y " +
                                  y.toString());
                            });
                          }

                          prevRoll = x;
                          prevPth = y;
                        },
                      ),
                      Row(
                        children: [
                          _telemetryButton(context),
                          _NavButton(context),
                        ],
                      ),
                    ],
                  ),
                  visible: _isOverlayActive,
                ),
              ])),
        ],
      ),
    );
  }

  _NavButton(context) {
    return IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          _navControlModal(context);
        });
  }

  _telemetryButton(context) {
    return IconButton(
        icon: const Icon(Icons.wifi),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      //child: _telemetry(context, _mqttState.getReceivedMsg),
                    ));
              });
        });
  }

  _disableOverlay(context) {
    return IconButton(
        icon: _isOverlayActive
            ? const Icon(Icons.layers_sharp,
                color: Color.fromRGBO(80, 174, 238, 1.0))
            : const Icon(Icons.layers_sharp),
        onPressed: () {
          setState(() {});
          _isOverlayActive = !_isOverlayActive;
        });
  }

  void _navControlModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: _navControlModalContent(),
              ));
        });
  }

  Widget _navControlModalContent() {
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => {_sendArmRequest()}, child: Text("Armar")),
            ElevatedButton(
                onPressed: () => {_sendDisarmRequest()},
                child: Text("Desarmar")),
            ElevatedButton(
                onPressed: () => {_sendRTHRequest()},
                child: Text("Return to Home")),
          ],
        ),
      ),
    );
  }

  void _sendArmRequest() {
    ControlData data = ControlData(ID: 2, p1: 0, p2: 0);
    _client.publish("Dronelink/arm", jsonEncode(data.toJson()));
  }

  void _sendDisarmRequest() {
    ControlData data = ControlData(ID: 3, p1: 0, p2: 0);
    _client.publish("Dronelink/disarm", jsonEncode(data.toJson()));
  }

  void _sendRTHRequest() {
    ControlData data = ControlData(ID: 4, p1: 0, p2: 0);
    _client.publish("Dronelink/rth", jsonEncode(data.toJson()));
  }

  void _initMQTT() {
    _client =
        MQTTClient(mqttServerIP, "APP", 'Dronelink/telemetry', _mqttState);
    _client.init();
    _client.connect();
  }

  void _initDronelinkDesktopComm() {
    address = Address.fromJson(jsonDecode(widget.scanResult!));
    socket = IO.io("ws://${address.ip}:${address.port}", <String, dynamic>{
      'transports': ['websocket'],
    });
    var streamSocket =
        IO.io("ws://${address.ip}:${address.port}/stream", <String, dynamic>{
      'transports': ['websocket'],
    });

    var telemetrySocket =
        IO.io("ws://${address.ip}:${address.port}/telemetry", <String, dynamic>{
      'transports': ['websocket'],
    });

    telemetrySocket.onConnect((client) {
      _isConnectedTelemetry = true;
      print("Connected to telemetry service!");
    });

    telemetrySocket.onDisconnect((client) {
      print("Disconnected from telemetry service!");
      _isConnectedTelemetry = false;
    });

    socket.onConnect((client) {
      print('connect');
      socket.emit('msg', address.token);
      streamSocket.emit('msg', videoUri);
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (data) => print(data));
  }

  void _updateTelemetry(String rawTelemetry) {
    if (rawTelemetry != "") {
      telemetry = Telemetry.fromJson(jsonDecode(rawTelemetry));
      if (_isConnectedTelemetry) {
        telemetrySocket.emit(rawTelemetry);
      }
    }
  }

  _telemetry(BuildContext context, String msg) {
    if (msg == "") {
      //incompleto
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
              child: Column(
            children: [
              Container(child: Text("Telemetría no disponible")),
              const Center(child: CircularProgressIndicator()),
            ],
          )));
    } else
      //  _updateTelemetry(msg);
      return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
                child: Container(
              child: Column(
                children: [
                  Text("Pitch: " + telemetry.pitch.toString()),
                  Text("Roll " + telemetry.roll.toString()),
                  Text("Altitude" + telemetry.altitude.toString()),
                  Text("Speed" + telemetry.speed.toString()),
                  Text("Latitude" + telemetry.latitude.toString()),
                  Text("Longitude: " + telemetry.longitude.toString())
                ],
              ),
            )),
          ));
  }
}
