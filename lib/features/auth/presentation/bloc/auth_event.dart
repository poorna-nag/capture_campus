import 'package:capture_campus/features/auth/data/user_model.dart';

class AuthEvent {}

class GetUserEvent extends AuthEvent {}

class SingupAuthEvent extends AuthEvent {
  UserModel userModel;
  SingupAuthEvent({required this.userModel});
}

class LoginAuthEvent extends AuthEvent {
  final String userEmail;
  final String passCode;

  LoginAuthEvent({required this.userEmail, required this.passCode});
}

class NavToSingScreenEvent extends AuthEvent {}

class NavTologinScreenEvent extends AuthEvent {}
