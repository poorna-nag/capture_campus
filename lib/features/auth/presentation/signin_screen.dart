import 'package:capture_campus/features/auth/data/user_model.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_event.dart';
import 'package:capture_campus/features/auth/presentation/login_screen.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:capture_campus/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController phNum = TextEditingController();
  TextEditingController campusName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController passCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            " WellCome ",
            style: GoogleFonts.abrilFatface(
              fontWeight: FontWeight.bold,
              fontSize: 42,
              color: Colors.amberAccent,
              shadows: const [Shadow(blurRadius: 10)],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'login useing your campus email to save your clicks',
            style: GoogleFonts.abrilFatface(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: campusName,
            decoration: InputDecoration(
              label: Text("Enter your name or campus name "),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: email,
            decoration: InputDecoration(
              label: Text("Enter Your Email"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: phNum,
            decoration: InputDecoration(
              label: Text("Enter Your phone"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: passCode,
            decoration: InputDecoration(
              label: Text("Create PassCode"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 20),

          logButton(() {
            context.read<AuthBloc>().add(
              SingupAuthEvent(
                userModel: UserModel(
                  campusName: campusName.text,
                  email: email.text,
                  passCode: passCode.text,
                ),
              ),
            );
          }, "Register Now"),

          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(NavTologinScreenEvent());
            },
            child: Text(" Login Page  ", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
