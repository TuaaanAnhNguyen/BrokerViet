// lib/services/auth/auth_service.dart

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String uid;
  final String name;
  final String email;
  final String avatarPath;
  final String memberTier;

  AuthSuccess({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.memberTier,
  });
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

class LogoutRequested extends AuthEvent {}

class AuthService extends Bloc<AuthEvent, AuthState> {
  AuthService() : super(AuthInitial()) {
    
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(seconds: 2));

        if (event.phone == '0123' && event.password == '0123') {
          emit(AuthSuccess(
            uid: 'USR-8821',
            name: 'Tuan Anh',
            email: 'anv@fe.edu.vn',
            avatarPath: 'assets/tam tender.jpg',
            memberTier: 'Thành viên Đồng',
          ));
        } else {
          emit(AuthFailure('Invalid phone number or password credentials.'));
        }
      } catch (e) {
        emit(AuthFailure('Server connection failure. Please try again.'));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(seconds: 1));

        if (event.phone == '0123') {
          emit(AuthFailure('Phone number already registered. Please log in.'));
        } else if (event.username.trim().isEmpty) {
          emit(AuthFailure('Username cannot be empty.'));
        } else {
          emit(AuthSuccess(
            uid: 'USR-8822',
            name: event.username,
            email: '${event.username.toLowerCase().replaceAll(' ', '')}@fe.edu.vn',
            avatarPath: 'assets/tam tender.jpg',
            memberTier: 'Thành viên Mới',
          ));
        }
      } catch (e) {
        emit(AuthFailure('Server connection failure. Please try again.'));
      }
    });

    on<LogoutRequested>((event, emit) {
      emit(AuthInitial());
    });
  }
}