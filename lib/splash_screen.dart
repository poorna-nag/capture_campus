import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/camara.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),

                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      "Poto",
                      style: GoogleFonts.abrilFatface(
                        fontWeight: FontWeight.bold,
                        fontSize: 52,
                        color: Colors.amberAccent,
                        shadows: const [Shadow(blurRadius: 10)],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "Capture Campus.",
                      style: GoogleFonts.abrilFatface(
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 10)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      "Your Lens, Our Campus Story",
                      style: GoogleFonts.afacad(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 8)],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: logButton(() {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => LoginScreen()),
                      // );
                      context.read<HomeBloc>().add(NavToHomeScreen());
                    }, "Let's Start"),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget logButton(VoidCallback onTap, String text) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 60,
      width: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.amberAccent, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
