import 'package:capture_campus/features/home/data/repo/camara_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CamaraRepoImpl extends CamaraRepo {
  @override
  Future<bool> requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var locationStatus = await Permission.location.request();

    return cameraStatus.isGranted && locationStatus.isGranted;
  }

  @override
  Future<Position?> getLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
