import 'dart:io';

import 'package:capture_campus/features/home/data/event_info.dart';
import 'package:image_picker/image_picker.dart';

class HomeEvent {}

class HomeLoadingEvent extends HomeEvent {}

class FatchData extends HomeEvent {
  final String name;
  final String email;

  FatchData({required this.name, required this.email});
}

class NavToHomeScreen extends HomeEvent {}

class UploadEvent extends HomeEvent {
  File? image;
}

class CamaraToCaptureEvent extends HomeEvent {
  final XFile? camara;

  CamaraToCaptureEvent({required this.camara});
}

class GetEventInfoEvent extends HomeEvent {
  final EventInfo eventInfo;

  GetEventInfoEvent({required this.eventInfo});
}
