import 'package:geolocator/geolocator.dart';

Future<Position> determinePositionSettings() async {
  bool locationEnabled;
  LocationPermission permission;

  locationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!locationEnabled) {
    
    return Future.error('La localización está desactivada, es necesaria para el funcionamiento normal de la applicación.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {

      return Future.error('La localización está desactivada');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'La localización está desactivada de forma permanente..');
  } 

  return await Geolocator.getCurrentPosition();
}