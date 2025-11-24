import 'dart:async';
import 'package:capture_campus/core/navigation/navaigation_service.dart';
import 'package:capture_campus/features/home/data/event_info.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final picker = ImagePicker();
  HomeBloc() : super(HomeInitState()) {
    on<HomeLoadingEvent>(_onHomeLoadingEvent);
    on<NavToHomeScreen>(_onNavToHomeScreen);
    on<UploadEvent>(_onUploadEvent);
    on<OpenCameraEvent>(_onOpenCameraEvent);
    on<GetEventInfoEvent>(_onGetEventInfoEvent);
  }

  FutureOr<void> _onNavToHomeScreen(
    NavToHomeScreen event,
    Emitter<HomeState> emit,
  ) {
    NavigationService.pushNamed(routeName: AppRoutes.home);
  }

  FutureOr<void> _onUploadEvent(
    UploadEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final List<XFile> images = await picker.pickMultiImage();

      emit(UploadEventState(pickImag: images));
      NavigationService.pushNamed(
        routeName: AppRoutes.addInfo,
        arguments: {'images': event.image},
      ).then((value) {
        if (value is EventInfo) {
          add(GetEventInfoEvent(eventInfo: value));
        }
      });
    } catch (e) {
      emit(HomeErrorState(error: state.toString()));
    }
  }

  FutureOr<void> _onHomeLoadingEvent(
    HomeLoadingEvent event,
    Emitter<HomeState> emit,
  ) {
    try {
      emit(HomeloadedState());
    } catch (e) {
      emit(HomeErrorState(error: state.toString()));
    }
  }

  FutureOr<void> _onGetEventInfoEvent(
    GetEventInfoEvent event,
    Emitter<HomeState> emit,
  ) {
    List<EventInfo> currentEventInfo = [];
    if (state is GetEventInfoState) {
      currentEventInfo = List<EventInfo>.from(
        (state as GetEventInfoState).eventInfo,
      );
    }
    final eventUpdate = List<EventInfo>.from(currentEventInfo)
      ..add(event.eventInfo);
    emit(GetEventInfoState(eventInfo: eventUpdate));
  }

  FutureOr<void> _onOpenCameraEvent(
    OpenCameraEvent event,
    Emitter<HomeState> emit,
  ) async {
    NavigationService.pushNamed(routeName: AppRoutes.camara).then((value) {
      if (value is XFile) {
        NavigationService.pushNamed(
          routeName: AppRoutes.addInfo,
          arguments: {
            'images': [value],
          },
        ).then((value) {
          if (value is EventInfo) {
            add(GetEventInfoEvent(eventInfo: value));
          }
        });
      }
    });

    // final image = await picker.pickImage(source: ImageSource.camera);
  }
}
