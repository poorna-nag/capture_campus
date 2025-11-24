import 'package:capture_campus/features/home/presentation/widgets/add_info_screen.dart';
import 'package:capture_campus/features/home/presentation/widgets/camera_screen.dart';
import 'package:capture_campus/features/home/presentation/widgets/home_screen.dart';
import 'package:capture_campus/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> pushNamed<T extends Object?>({
    required String routeName,
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<
    T extends Object?,
    TO extends Object?
  >({required String routeName, Object? arguments, TO? result}) {
    return navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop() {
    return navigatorKey.currentState!.pop();
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.sp:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
          settings: settings,
        );
      case AppRoutes.camara:
        return MaterialPageRoute(
          builder: (_) => CameraScreen(),
          settings: settings,
        );
      case AppRoutes.addInfo:
        final args = settings.arguments as Map<String, dynamic>?;
        final List<XFile?> imageNullable =
            args?['images'] as List<XFile?>? ?? [];
        final List<XFile> image = imageNullable.whereType<XFile>().toList();
        return MaterialPageRoute(
          builder: (_) => AddInfoScreen(images: image),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}

class AppRoutes {
  static const String sp = '/sp';
  static const String home = "/home";
  static const String addInfo = "/addInfo";
  static const String camara = '/camara';
}
