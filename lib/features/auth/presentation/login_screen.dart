import 'package:capture_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_event.dart';

import 'package:capture_campus/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc()..add(LoginAuthEvent(userEmail: '', passCode: '')),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "LogIn Here",
                style: GoogleFonts.abrilFatface(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  color: Colors.amberAccent,
                  shadows: const [Shadow(blurRadius: 10)],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'login useing your campus email to save your clicks',
                style: GoogleFonts.abrilFatface(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hint: Text('enter your campus email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hint: Text('enter passcode'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              logButton(() {
                context.read<AuthBloc>().add(
                  LoginAuthEvent(userEmail: '', passCode: ''),
                );
              }, 'Login'),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(NavToSingScreenEvent());
                },
                child: Text("Register Here >>"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
