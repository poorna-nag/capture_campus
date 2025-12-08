class AuthState {}

class InitAuthState extends AuthState {}

class LoadingAuthState extends AuthState {}

class LoadedAuthState extends AuthState {}

class ErrorAuthState extends AuthState {
  final String error;

  ErrorAuthState({required this.error});
}

class SingupAuthStete extends AuthState {}

class LoginAuthState extends AuthState {}
