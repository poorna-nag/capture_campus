import 'package:capture_campus/core/service/google_drive_service.dart';
import 'package:capture_campus/features/home/data/event_info.dart';
import 'package:flutter/material.dart';

class GoogleSignInScreen extends StatefulWidget {
  final EventInfo? eventInfo;
  const GoogleSignInScreen({super.key, this.eventInfo});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  bool _loading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    if (widget.eventInfo != null) {
      _handleSignInAndUpload();
    }
  }

  Future<void> _handleSignInAndUpload() async {
    setState(() {
      _loading = true;
      _status = "Signing in with Google...";
    });

    try {
      if (widget.eventInfo == null) {
        setState(() {
          _status = "No event data to upload";
          _loading = false;
        });
        return;
      }

      setState(() {
        _status = "Preparing upload...";
      });

      await _driveService.uploadEvent(widget.eventInfo!);

      if (!mounted) return;

      setState(() {
        _status = "Upload successful!";
        _loading = false;
      });

      // Show success message briefly before navigating back
      await Future.delayed(Duration(seconds: 1));

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      String errorMessage = e.toString();

      // Provide user-friendly error messages
      if (errorMessage.contains('sign_in_failed') ||
          errorMessage.contains('GMS') ||
          errorMessage.contains('PlatformException')) {
        errorMessage =
            'Google Sign-In failed. Please ensure:\n'
            '• Google Play Services is installed\n'
            '• You have internet connection\n'
            '• OAuth is configured in Firebase Console';
      } else if (errorMessage.contains('cancelled')) {
        errorMessage = 'Sign-in was cancelled';
      } else if (errorMessage.contains('No files')) {
        errorMessage = 'No files found to upload';
      }

      setState(() {
        _status = "Error: $errorMessage";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect Google Drive")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sign in with Google to upload your files to Drive.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _status!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _status!.contains('Error') ||
                              _status!.contains('Failed')
                          ? Colors.red
                          : _status!.contains('successful')
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _handleSignInAndUpload,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Continue with Google"),
                    ),
              if (!_loading &&
                  _status != null &&
                  (_status!.contains('Error') || _status!.contains('Failed')))
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Go Back'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
