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
    on<NavToAddInfoEvent>(_onNavToAddInfoEvent);
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
      if (images.isEmpty) return;

      final EventInfo? info = await NavigationService.pushNamed(
        routeName: AppRoutes.addInfo,
        arguments: {'images': images},
      );

      if (info == null) return;

      final bool? googleSignIn = await NavigationService.pushNamed(
        routeName: AppRoutes.googleSignup,
        arguments: {'eventInfo': info},
      );

      if (googleSignIn != true) return;

      add(GetEventInfoEvent(eventInfo: info));
    } catch (e) {
      emit(HomeErrorState(error: e.toString()));
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
    final XFile? image = await NavigationService.pushNamed(
      routeName: AppRoutes.camara,
    );
    if (image == null) return;

    final EventInfo? info = await NavigationService.pushNamed(
      routeName: AppRoutes.addInfo,
      arguments: {
        'images': [image],
      },
    );
    if (info == null) return;

    final bool? googleSignIn = await NavigationService.pushNamed(
      routeName: AppRoutes.googleSignup,
      arguments: {'eventInfo': info},
    );

    if (googleSignIn == true) {
      add(GetEventInfoEvent(eventInfo: info));
    }
  }

  FutureOr<void> _onNavToAddInfoEvent(
    NavToAddInfoEvent event,
    Emitter<HomeState> emit,
  ) async {
    final images = event.selectedFiles;

    final EventInfo? info = await NavigationService.pushNamed(
      routeName: AppRoutes.addInfo,
      arguments: {'images': images},
    );

    if (info == null) return;

    final bool? googleSignIn = await NavigationService.pushNamed(
      routeName: AppRoutes.googleSignup,
      arguments: {'eventInfo': info},
    );

    if (googleSignIn == true) {
      add(GetEventInfoEvent(eventInfo: info));
    }
  }
}
