// lib/services/auth/auth_service.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

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
  final _supabase = Supabase.instance.client;

  String _formatPhoneNumber(String phone) {
    phone = phone.trim();
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    if (!phone.startsWith('+')) {
      return '+84$phone'; // Mặc định là VN nếu không có dấu +
    }
    return phone;
  }

  AuthService() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final formattedPhone = _formatPhoneNumber(event.phone);
        final response = await _supabase.auth.signInWithPassword(
          phone: formattedPhone,
          password: event.password,
        );
// ... tiếp tục code cũ

        if (response.user != null) {
          emit(AuthSuccess(
            uid: response.user!.id,
            name: response.user!.userMetadata?['username'] ?? 'User',
            email: response.user!.email ?? '',
            avatarPath: 'assets/tam tender.jpg',
            memberTier: 'Thành viên Đồng',
          ));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('Login failed. Please try again.'));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final formattedPhone = _formatPhoneNumber(event.phone);
        final response = await _supabase.auth.signUp(
          phone: formattedPhone,
          password: event.password,
          data: {'username': event.username},
        );

        if (response.user != null) {
          emit(AuthSuccess(
            uid: response.user!.id,
            name: response.user!.userMetadata?['username'] ?? event.username,
            email: response.user!.email ?? '',
            avatarPath: 'assets/tam tender.jpg',
            memberTier: 'Thành viên Mới',
          ));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('Registration failed.'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _supabase.auth.signOut();
      emit(AuthInitial());
    });
  }
}
