// lib/services/auth/auth_service.dart

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String username;
  AuthSuccess(this.username);
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  LoginRequested(this.phone, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String phone;
  final String password;
  SignUpRequested(this.username, this.phone, this.password);
}

class AuthService extends Bloc<AuthEvent, AuthState> {
  AuthService() : super(AuthInitial()) {
    // Simulated login logic for demonstration purposes
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(seconds: 2));

        if (event.phone == '0123456789' && event.password == 'password123') {
          emit(AuthSuccess('Tuan Anh'));
        } else {
          emit(AuthFailure('Invalid phone number or password credentials.'));
        }
      } catch (e) {
        emit(AuthFailure('Server connection failure. Please try again.'));
      }
    });

    // Simulated sign-up logic for demonstration purposes
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(seconds: 1));

        if (event.phone == '0123456789') {
          emit(AuthFailure('Phone number already registered. Please log in.'));
        } else if (event.username.trim().isEmpty) {
          emit(AuthFailure('Username cannot be empty.'));
        } else {
          emit(AuthSuccess(event.username));
        }
      } catch (e) {
        emit(AuthFailure('Server connection failure. Please try again.'));
      }
    });
  }
}
