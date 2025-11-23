// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:image_picker/image_picker.dart';

import 'package:capture_campus/features/home/data/event_info.dart';

class HomeState {}

class HomeInitState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeloadedState extends HomeState {}

class HomeErrorState extends HomeState {
  final String error;

  HomeErrorState({required this.error});
}

class UploadEventState extends HomeState {
  final List<XFile?> pickImag;

  UploadEventState({required this.pickImag});
}

class CamaraToCaptureEventState extends HomeState {
  final XFile? camara;

  CamaraToCaptureEventState({required this.camara});
}

class GetEventInfoState extends HomeState {
  List<EventInfo> eventInfo;
  GetEventInfoState({required this.eventInfo});

  GetEventInfoState copyWith({List<EventInfo>? events}) {
    return GetEventInfoState(eventInfo: eventInfo);
  }
}
