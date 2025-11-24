import 'package:geolocator/geolocator.dart';

abstract class CamaraRepo {
  Future<bool> requestPermissions();
  Future<Position?> getLiveLocation();
}
