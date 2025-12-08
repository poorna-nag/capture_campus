import 'dart:io';
import 'package:camera/camera.dart';
import 'package:capture_campus/core/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isRecording = false;
  int selectedCameraIndex = 0;

  double? latitude;
  double? longitude;

  String? fullAddress;
  String? city;
  String? state;
  String? country;

  final List<File> recentCaptured = [];

  FlashMode _flashMode = FlashMode.off;
  bool _isCameraInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !(_controller?.value.isInitialized ?? false))
      return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCameraController(selectedCameraIndex);
    }
  }

  Future<void> initialize() async {
    if (!await requestPermissions()) return;
    await fetchLocationAndAddress();
    await loadAvailableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      await initializeCameraController(selectedCameraIndex);
    }
  }

  Future<bool> requestPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final locationPermission = await Permission.location.request();
    final microphonePermission = await Permission.microphone.request();

    return cameraPermission.isGranted &&
        locationPermission.isGranted &&
        microphonePermission.isGranted;
  }

  Future<void> loadAvailableCameras() async {
    try {
      cameras = await availableCameras();
    } catch (e) {
      cameras = [];
    }
  }

  Future<void> initializeCameraController(int cameraIndex) async {
    if (cameras == null || cameras!.isEmpty) return;
    _isCameraInitializing = true;
    setState(() {});

    try {
      await _controller?.dispose();

      final desc = cameras![cameraIndex];
      _controller = CameraController(
        desc,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      try {
        await _controller!.setFlashMode(_flashMode);
      } catch (_) {}
    } catch (e) {
    } finally {
      _isCameraInitializing = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> fetchLocationAndAddress() async {
    try {
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

      if (mounted) setState(() {});
    } catch (e) {}
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
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 75,
              width: 75,
              child: Image.network(
                "https://plus.unsplash.com/premium_photo-1713375115009-9dfaa151ab61?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                height: 75,
                width: 75,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${city ?? ''}, ${state ?? ''}, ${country ?? ''} ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                Text(
                  fullAddress ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                Text(
                  latitude != null && longitude != null
                      ? "Lat ${latitude!.toStringAsFixed(6)}°  |  Long ${longitude!.toStringAsFixed(6)}°"
                      : "",
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

 Future<void> takePhoto() async {
  if (_controller == null || !_controller!.value.isInitialized) return;

  try {
    final XFile xfile = await _controller!.takePicture();

    final File saved = await StorageService.saveMedia(xfile, isImage: true);

    // Add to recent captured list
    recentCaptured.insert(0, saved);

    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Photo saved")),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to take photo: $e")),
    );
  }
}

  /// Start/stop video recording and save
  Future<void> toggleVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (!isRecording) {
        await _controller!.startVideoRecording();
        setState(() => isRecording = true);
      } else {
        final xfile = await _controller!.stopVideoRecording();
        final saved = await StorageService.saveMedia(xfile, isImage: false);
        setState(() => isRecording = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video saved")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Video recording failed")));
    }
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras!.length;
    await initializeCameraController(selectedCameraIndex);
  }

  Future<void> cycleFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    // Cycle: off -> auto -> always (torch) -> off
    try {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else {
        _flashMode = FlashMode.off;
      }
      await _controller!.setFlashMode(_flashMode);
      setState(() {});
    } catch (e) {
      // some devices may not support modes
    }
  }

  String flashModeLabel() {
    switch (_flashMode) {
      case FlashMode.auto:
        return "AUTO";
      case FlashMode.always:
        return "ON";
      case FlashMode.off:
      default:
        return "OFF";
    }
  }

  @override
  Widget build(BuildContext context) {
    final localController = _controller;

    if (_isCameraInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (localController == null || !localController.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Fullscreen Camera Preview
          Positioned.fill(child: CameraPreview(localController)),

          /// TOP BAR (Flash, Switch Camera, Gallery)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Flash button shows current mode label
                GestureDetector(
                  onTap: cycleFlashMode,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          flashModeLabel(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 10),

                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.cameraswitch_rounded,
                      onTap: switchCamera,
                    ),
                    SizedBox(width: 12),
                    CircleIconButton(
                      icon: Icons.photo_library_outlined,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => GalleryScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(left: 15, right: 15, bottom: 150, child: locationCard()),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (recentCaptured.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullImageScreen(
                                  image: recentCaptured.first,
                                ),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: recentCaptured.isNotEmpty
                              ? FileImage(recentCaptured.first)
                              : null,
                          backgroundColor: Colors.grey.shade800,
                        ),
                      ),

                      SizedBox(width: 50),

                      GestureDetector(
                        onTap: takePhoto,
                        child: Container(
                          height: 85,
                          width: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
                          ),
                        ),
                      ),

                      SizedBox(width: 50),

                      GestureDetector(
                        onTap: toggleVideoRecording,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: isRecording ? Colors.red : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.videocam,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
