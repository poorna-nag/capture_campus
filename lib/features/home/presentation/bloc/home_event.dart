import 'dart:io';
import 'package:capture_campus/features/home/data/event_info.dart';
import 'package:image_picker/image_picker.dart';

class HomeEvent {}

class HomeLoadingEvent extends HomeEvent {}

class NavToHomeScreen extends HomeEvent {}

class UploadEvent extends HomeEvent {
  File? image;
}

class OpenCameraEvent extends HomeEvent {
  // final List<XFile?>? takenPhoto;

  OpenCameraEvent(
    // {required this.takenPhoto}
  );
}

class GetEventInfoEvent extends HomeEvent {
  final EventInfo eventInfo;

  GetEventInfoEvent({required this.eventInfo});
}

class NavToAddInfoEvent extends HomeEvent {
  final List<XFile?> selectedFiles;

  NavToAddInfoEvent({required this.selectedFiles});
}


