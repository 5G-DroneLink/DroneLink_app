import 'dart:async';
import 'package:DroneLink/pages/QRreader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'MQTT/states/MQTTState.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MQTTState>(
        create: (context) => MQTTState(),
        child: MaterialApp(
          title: 'DroneLink',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            primaryColor: const Color.fromRGBO(19, 125, 197, 1.0),
          ),
          home: const MainPage(),
        ));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => QRreaderPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: EdgeInsets.all(30.0),
            child: Image(
                image: AssetImage("assets/logo_color_white_font_noBG.png")),
          )
        ]),
      ),
    );
  }
}
