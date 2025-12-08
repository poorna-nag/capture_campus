import 'dart:async';

import 'package:capture_campus/core/navigation/navaigation_service.dart';
import 'package:capture_campus/features/auth/data/repo/user_repo_impl.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_state.dart';
import 'package:capture_campus/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(InitAuthState()) {
    on<SingupAuthEvent>(_onSingupAuthEvent);
    on<LoginAuthEvent>(_onLoginAuthEvent);
    on<NavToSingScreenEvent>(_onNavToSingScreenEvent);
    on<NavTologinScreenEvent>(_onNavTologinScreenEvent);
  }

  FutureOr<void> _onSingupAuthEvent(
    SingupAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final singUp = await UserRepoImpl().singin(event.userModel);
      if (singUp) {
        emit(SingupAuthStete());
        NavigationService.pushNamed(routeName: AppRoutes.home);
      }
    } catch (_) {
      emit(ErrorAuthState(error: state.toString()));
    }
  }

  FutureOr<void> _onLoginAuthEvent(
    LoginAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final login = await UserRepoImpl().login(event.userEmail, event.passCode);
      if (login) {
        emit(LoginAuthState());
        NavigationService.pushNamed(routeName: AppRoutes.home);
      }
    } catch (e) {
      emit(ErrorAuthState(error: state.toString()));
    }
  }

  FutureOr<void> _onNavToSingScreenEvent(
    NavToSingScreenEvent event,
    Emitter<AuthState> emit,
  ) {
    NavigationService.pushNamed(routeName: AppRoutes.signup);
  }

  FutureOr<void> _onNavTologinScreenEvent(
    NavTologinScreenEvent event,
    Emitter<AuthState> emit,
  ) {
    NavigationService.pop();
  }
}
