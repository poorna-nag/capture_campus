import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   context.read<HomeBloc>().add(NavToHomeScreen());
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/camara.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 40,
              child: Text(
                "Poto",
                style: GoogleFonts.abrilFatface(
                  fontWeight: FontWeight.bold,
                  fontSize: 52,
                  color: Colors.amberAccent,
                  shadows: [Shadow(blurRadius: 10)],
                ),
              ),
            ),
            Positioned(
              top: 500,
              left: 35,
              child: Text(
                "Capture Campus.",
                style: GoogleFonts.abrilFatface(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10)],
                ),
              ),
            ),

            Positioned(
              top: 600,
              left: 35,
              child: Text(
                "Your Lens, Our Campus Story",
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8)],
                ),
              ),
            ),

            Positioned(
              bottom: 150,
              left: 120,
              child: GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(NavToHomeScreen());
                },
                child: Container(
                  height: 60,
                  width: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.amberAccent, width: 2),
                  ),
                  child: const Text(
                    "Let's Start",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
