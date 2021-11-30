import 'package:DroneLink/pages/GPS.dart';
import 'package:DroneLink/pages/Home.dart';
import 'package:flutter/material.dart';

Widget drawer(BuildContext context) {
  return Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
              alignment: Alignment.center,
              matchTextDirection: true,
              repeat: ImageRepeat.noRepeat,
              image: AssetImage("assets/logo_color_white_font_noBG.png"),
            )),
            child: null,
          ),
          ListTile(
            title: const Text('Control Directo'),
            onTap: () {
             WidgetsBinding.instance!.addPostFrameCallback((_) { Navigator.pushReplacement( context, MaterialPageRoute( builder: (context) => Home(), )); });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('GPS'),
            onTap: () {
             WidgetsBinding.instance!.addPostFrameCallback((_) { Navigator.pushReplacement( context, MaterialPageRoute( builder: (context) => GPS(), )); });
              Navigator.pop(context);
            },
          ),
        ]));
}