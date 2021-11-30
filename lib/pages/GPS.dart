import 'package:flutter/material.dart';
import 'package:DroneLink/widgets/drawer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:DroneLink/functions/functions.dart';

class GPS extends StatefulWidget {
  static const String routeName = '/gps';

  @override
  _GPSState createState() => _GPSState();
}

class _GPSState extends State<GPS> {
  Position userPosition = Position(
      latitude: 0.0,
      longitude: 0.0,
      altitude: 0.0,
      accuracy: 0.0,
      timestamp: null,
      speed: 0.0,
      heading: 0.0,
      speedAccuracy: 0.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(drawer: drawer(context), body: GPSBody(context));
  }

  @override
  void initState() {
    super.initState();
    determinePositionSettings();
    getLocation();
  }

  void getLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position obtainedPosition) {
      setState(() {
        userPosition = obtainedPosition;
      });
    });
  }

  Widget GPSBody(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FlutterMap(
        options: MapOptions(
          center: latLng.LatLng(userPosition.latitude, userPosition.longitude),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return Text("© OpenStreetMap contributors");
            },
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: latLng.LatLng(
                    userPosition.latitude, userPosition.longitude),
                builder: (ctx) => Container(
                  child: Icon(Icons.circle,
                      color: Color.fromRGBO(80, 174, 238, 1.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
