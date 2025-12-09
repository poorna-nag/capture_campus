import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

import '../../features/home/data/event_info.dart';

class GoogleDriveService {
  GoogleDriveService()
    : _googleSignIn = GoogleSignIn(
        scopes: [drive.DriveApi.driveFileScope],
        // Add serverClientId if you have one from Firebase Console
        // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );

  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentAccount;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Try silent sign-in first
      _currentAccount = await _googleSignIn.signInSilently();

      // If silent sign-in fails, show sign-in UI
      if (_currentAccount == null) {
        _currentAccount = await _googleSignIn.signIn();
      }

      return _currentAccount;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      // Re-throw with more context
      throw Exception(
        'Failed to sign in with Google: $e\n\n'
        'Please ensure:\n'
        '1. Google Play Services is installed and updated\n'
        '2. You have internet connection\n'
        '3. OAuth client is configured in Firebase Console\n'
        '4. SHA-1 fingerprint is added to Firebase project',
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentAccount = null;
  }

  Future<void> uploadEvent(EventInfo eventInfo) async {
    try {
      final account = await signIn();
      if (account == null) {
        throw Exception("Google sign-in was cancelled or failed");
      }

      debugPrint('Signed in as: ${account.email}');

      // Get auth headers
      final authHeaders = await account.authHeaders;
      if (authHeaders.isEmpty) {
        throw Exception('Failed to get authentication headers');
      }

      final client = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(client);

      // Create a folder for this event
      final folderName =
          "CaptureCampus_${DateTime.now().toIso8601String().split('T')[0]}";
      drive.File? eventFolder;

      try {
        // Try to find existing folder or create new one
        final folderFile = drive.File()
          ..name = folderName
          ..mimeType = 'application/vnd.google-apps.folder';
        eventFolder = await driveApi.files.create(folderFile);
        debugPrint('Created folder: ${eventFolder.id}');
      } catch (e) {
        debugPrint('Folder creation issue (continuing): $e');
      }

      // Upload each media file
      int uploadedCount = 0;
      for (final xfile in eventInfo.images) {
        final file = File(xfile.path);
        if (!await file.exists()) {
          debugPrint('File does not exist: ${file.path}');
          continue;
        }

        try {
          final driveFile = drive.File()..name = p.basename(file.path);

          // Add to folder if created
          if (eventFolder?.id != null) {
            driveFile.parents = [eventFolder!.id!];
          }

          final media = drive.Media(file.openRead(), await file.length());
          await driveApi.files.create(driveFile, uploadMedia: media);
          uploadedCount++;
          debugPrint('Uploaded: ${driveFile.name}');

          // Upload sidecar metadata if present
          final metadataFile = File("${file.path}.metadata.json");
          if (await metadataFile.exists()) {
            final metaDriveFile = drive.File()
              ..name = "${p.basename(file.path)}.metadata.json";
            if (eventFolder?.id != null) {
              metaDriveFile.parents = [eventFolder!.id!];
            }
            await driveApi.files.create(
              metaDriveFile,
              uploadMedia: drive.Media(
                metadataFile.openRead(),
                await metadataFile.length(),
              ),
            );
            debugPrint('Uploaded metadata: ${metaDriveFile.name}');
          }
        } catch (e) {
          debugPrint('Error uploading ${file.path}: $e');
          // Continue with other files
        }
      }

      if (uploadedCount == 0) {
        throw Exception('No files were uploaded. Please check file paths.');
      }

      // Upload event summary
      try {
        final summaryContent = _buildEventSummary(eventInfo);
        final summaryBytes = utf8.encode(summaryContent);
        final summaryFile = drive.File()
          ..name = "event_${DateTime.now().toIso8601String()}.txt";
        if (eventFolder?.id != null) {
          summaryFile.parents = [eventFolder!.id!];
        }
        await driveApi.files.create(
          summaryFile,
          uploadMedia: drive.Media(
            Stream<List<int>>.value(summaryBytes),
            summaryBytes.length,
          ),
        );
        debugPrint('Uploaded summary file');
      } catch (e) {
        debugPrint('Error uploading summary: $e');
        // Don't fail the whole operation if summary fails
      }

      debugPrint(
        'Upload completed successfully. $uploadedCount files uploaded.',
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  String _buildEventSummary(EventInfo eventInfo) {
    final buffer = StringBuffer()
      ..writeln("Event Name : ${eventInfo.eventName}")
      ..writeln("Description: ${eventInfo.eventInfo}")
      ..writeln("Created By : ${eventInfo.userName}")
      ..writeln("Date       : ${eventInfo.date}")
      ..writeln("Files      :");

    for (final image in eventInfo.images) {
      buffer.writeln("- ${p.basename(image.path)}");
    }

    return buffer.toString();
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
