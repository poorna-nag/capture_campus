import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  double? latitude;
  double? longitude;

  String? fullAddress;
  String? city;
  String? state;
  String? country;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  Future<void> initialize() async {
    if (!await requestPermissions()) return;

    await initCamera();
    await fetchLocationAndAddress();
  }

  Future<bool> requestPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final locationPermission = await Permission.location.request();

    return cameraPermission.isGranted && locationPermission.isGranted;
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    setState(() {});
  }

  Future<void> fetchLocationAndAddress() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    latitude = pos.latitude;
    longitude = pos.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude!,
      longitude!,
    );

    final place = placemarks.first;

    city = place.locality;
    state = place.administrativeArea;
    country = place.country;

    fullAddress =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

    setState(() {});
  }

  String formattedDateTime() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}  "
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}  "
        "GMT +05:30";
  }

  Widget locationCard() {
    if (latitude == null || longitude == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "Fetching location...",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://maps.googleapis.com/maps/api/staticmap?"
              "center=$latitude,$longitude"
              "&zoom=18"
              "&size=200x200"
              "&maptype=satellite"
              "&markers=color:red%7C$latitude,$longitude"
              "&key=YOUR_GOOGLE_MAPS_API_KEY",
              height: 75,
              width: 75,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$city, $state, $country 🇮🇳",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),

                Text(
                  fullAddress ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 4),

                Text(
                  "Lat ${latitude!.toStringAsFixed(6)}°  |  "
                  "Long ${longitude!.toStringAsFixed(6)}°",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 4),

                Text(
                  formattedDateTime(),
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),

          Positioned(left: 15, right: 15, bottom: 130, child: locationCard()),

          Positioned(
            bottom: 35,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final photo = await _controller!.takePicture();
                  Navigator.pop(context, photo);
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
