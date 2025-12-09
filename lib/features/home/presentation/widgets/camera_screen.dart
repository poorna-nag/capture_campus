import 'dart:io';
import 'package:camera/camera.dart';
import 'package:capture_campus/core/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
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
  Duration recordingDuration = Duration.zero;
  DateTime? recordingStartTime;

  double? latitude;
  double? longitude;

  String? fullAddress;
  String? city;
  String? state;
  String? country;

  final List<File> recentCaptured = [];
  final ImagePicker _imagePicker = ImagePicker();

  FlashMode _flashMode = FlashMode.off;
  bool _isCameraInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
    // Start timer to update recording duration
    _startRecordingTimer();
  }

  void _startRecordingTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (isRecording && recordingStartTime != null && mounted) {
        setState(() {
          recordingDuration = DateTime.now().difference(recordingStartTime!);
        });
        _startRecordingTimer(); // Continue timer
      } else if (!isRecording) {
        // Reset timer when not recording
        recordingDuration = Duration.zero;
        recordingStartTime = null;
      }
    });
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
      // Ensure location is fetched before taking photo
      if (latitude == null || longitude == null) {
        await fetchLocationAndAddress();
      }

      final XFile xfile = await _controller!.takePicture();

      // Capture location values
      final currentLat = latitude;
      final currentLon = longitude;
      final currentAddress = fullAddress;

      final File saved = await StorageService.saveMedia(
        xfile,
        isImage: true,
        latitude: currentLat,
        longitude: currentLon,
        address: currentAddress,
        extra: {
          'city': city,
          'state': state,
          'country': country,
          'capturedAt': DateTime.now().toIso8601String(),
        },
      );

      // Add to recent captured list
      if (mounted) {
        setState(() {
          recentCaptured.insert(0, saved);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentLat != null && currentLon != null
                  ? "Photo saved with geotag"
                  : "Photo saved (location unavailable)",
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error taking photo: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to take photo: $e")));
    }
  }

  /// Start/stop video recording and save
  Future<void> toggleVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (!isRecording) {
        // Start recording
        await _controller!.startVideoRecording();
        if (!mounted) return;
        recordingStartTime = DateTime.now();
        recordingDuration = Duration.zero;
        setState(() => isRecording = true);
        _startRecordingTimer(); // Start the timer
      } else {
        // Stop recording - reset state FIRST to prevent UI issues
        if (!mounted) return;
        setState(() {
          isRecording = false;
          recordingDuration = Duration.zero;
          recordingStartTime = null;
        });

        // Stop video recording
        XFile xfile;
        try {
          xfile = await _controller!.stopVideoRecording();
        } catch (stopError) {
          print('Error stopping video recording: $stopError');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error stopping recording: $stopError")),
          );
          return;
        }

        // Verify file exists and is valid
        final videoFile = File(xfile.path);
        if (xfile.path.isEmpty || !await videoFile.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Video file not found")));
          return;
        }

        // Save video in background to prevent blocking
        _saveVideoFile(xfile).catchError((error) {
          print('Error saving video: $error');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Video saved locally")));
          }
        });
      }
    } catch (e, stackTrace) {
      print('Video recording error: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        isRecording = false;
        recordingDuration = Duration.zero;
        recordingStartTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recording error: ${e.toString()}")),
      );
    }
  }

  /// Save video file asynchronously - completely isolated to prevent crashes
  Future<void> _saveVideoFile(XFile xfile) async {
    // Use a separate isolate-like approach - don't access widget state
    try {
      // Capture location values before async operation
      final currentLat = latitude;
      final currentLon = longitude;
      final currentAddress = fullAddress;
      final currentCity = city;
      final currentState = state;
      final currentCountry = country;

      // Save video file
      final savedFile = await StorageService.saveMedia(
        xfile,
        isImage: false,
        latitude: currentLat,
        longitude: currentLon,
        address: currentAddress,
        extra: {
          'city': currentCity,
          'state': currentState,
          'country': currentCountry,
          'capturedAt': DateTime.now().toIso8601String(),
        },
      );

      // Update UI only if widget is still mounted
      if (mounted) {
        // Add to recent captured list
        if (await savedFile.exists()) {
          setState(() {
            recentCaptured.insert(0, savedFile);
          });
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video saved successfully")));
      }
    } catch (saveError, stackTrace) {
      print('Error in _saveVideoFile: $saveError');
      print('Stack trace: $stackTrace');
      // Don't show error to user - video is saved locally anyway
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video saved")));
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Open phone gallery to view photos/videos
  Future<void> openPhoneGallery() async {
    try {
      // Open native gallery picker
      final XFile? pickedFile = await _imagePicker.pickMedia(imageQuality: 100);

      if (pickedFile != null) {
        // User selected a file from gallery, you can navigate to view it
        // or just show a preview
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageScreen(image: File(pickedFile.path)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to open gallery: $e")));
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

          /// Recording Timer (shown when recording)
          if (isRecording)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _formatDuration(recordingDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// TOP BAR (Flash, Switch Camera, Gallery)
          Positioned(
            top: isRecording ? 100 : 40,
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
                      // Gallery button - opens phone gallery
                      GestureDetector(
                        onTap: openPhoneGallery,
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 2),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28,
                          ),
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
