import 'package:capture_campus/core/navigation/navaigation_service.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/firebase_options.dart';
import 'package:capture_campus/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ],

      child: MaterialApp(
        theme: ThemeData.dark(),
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: NavigationService.onGenerateRoute,
        initialRoute: AppRoutes.sp,
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: SplashScreen()),
      ),
    );
  }
}
