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
    on<FatchData>(_onFatchData);
    on<CamaraToCaptureEvent>(_onCamaraToCaptureEvent);
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
      );
    } catch (e) {
      emit(HomeErrorState(error: state.toString()));
    }
  }

  FutureOr<void> _onFatchData(FatchData event, Emitter<HomeState> emit) {}

  FutureOr<void> _onHomeLoadingEvent(
    HomeLoadingEvent event,
    Emitter<HomeState> emit,
  ) {
    try {
      emit(HomeloadedState(eventInfo: const []));
    } catch (e) {
      emit(HomeErrorState(error: state.toString()));
    }
  }

  FutureOr<void> _onCamaraToCaptureEvent(
    CamaraToCaptureEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final camara = await picker.pickImage(source: ImageSource.camera);
      if (camara != null) {
        emit(CamaraToCaptureEventState(camara: camara));
        NavigationService.pushNamed(
          routeName: AppRoutes.addInfo,
          arguments: {'images': event.camara},
        );
      }
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
    }
  }

  FutureOr<void> _onGetEventInfoEvent(
    GetEventInfoEvent event,
    Emitter<HomeState> emit,
  ) {
    List<EventInfo> currentEventInfo = [];
    if (state is HomeloadedState) {
      currentEventInfo = List<EventInfo>.from(
        (state as HomeloadedState).eventInfo,
      );
    }
    final eventUpdate = List<EventInfo>.from(currentEventInfo)
      ..add(event.eventInfo);
    emit(HomeloadedState(eventInfo: eventUpdate));
  }
}
