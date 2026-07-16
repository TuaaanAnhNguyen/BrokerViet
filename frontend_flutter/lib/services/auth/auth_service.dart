// lib/services/auth/auth_service.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../notification/firebase_cloud_messaging_handler.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPasswordResetOtpSent extends AuthState {}

class AuthPasswordResetSuccess extends AuthState {}

class AuthPasswordResetEmailSent extends AuthState {}

class AuthSuccess extends AuthState {
  final String uid;
  final String name;
  final String email;
  final String avatarPath;
  final String role;

  AuthSuccess({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.role,
  });
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  LoginRequested(this.phone, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String phone;
  final String password;
  final String role;
  SignUpRequested(this.username, this.phone, this.password, this.role);
}

class ForgotPasswordByPhoneRequested extends AuthEvent {
  final String phone;

  ForgotPasswordByPhoneRequested(this.phone);
}

class ForgotPasswordPhoneConfirmed extends AuthEvent {
  final String phone;
  final String otpCode;
  final String newPassword;

  ForgotPasswordPhoneConfirmed({
    required this.phone,
    required this.otpCode,
    required this.newPassword,
  });
}

class ForgotPasswordByEmailRequested extends AuthEvent {
  final String email;

  ForgotPasswordByEmailRequested(this.email);
}

class UpdateAvatarRequested extends AuthEvent {
  final String imagePath;
  UpdateAvatarRequested(this.imagePath);
}

class LogoutRequested extends AuthEvent {}

class AuthService extends Bloc<AuthEvent, AuthState> {
  final _supabase = Supabase.instance.client;

  String _formatPhoneNumber(String phone) {
    phone = phone.trim().replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    if (!phone.startsWith('+')) {
      return '+84$phone';
    }
    return phone;
  }

  Future<AuthSuccess?> _fetchProfileAndBuildSuccessState(
    User user, {
    String? fallbackRole,
  }) async {
    final userId = user.id;
    final profileData = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    final profileUsername = profileData != null
        ? profileData['username']
        : null;
    final profileRole = profileData != null ? profileData['role'] : null;
    final profileAvatar = profileData != null
        ? profileData['avatar_url']
        : null;

    return AuthSuccess(
      uid: userId,
      name: profileUsername ?? user.userMetadata?['username'] ?? 'Người dùng',
      email: user.email ?? '',
      avatarPath: profileAvatar ?? 'assets/default_profile.png',
      role: profileRole ?? fallbackRole ?? 'CUSTOMER',
    );
  }

  AuthService() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        emit(AuthLoading());
        try {
          final successState = await _fetchProfileAndBuildSuccessState(
            currentUser,
          );
          if (successState != null) {
            await FcmHandler().registerCurrentDevice();
            emit(successState);
          } else {
            emit(AuthInitial());
          }
        } catch (_) {
          emit(AuthInitial());
        }
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final formattedPhone = _formatPhoneNumber(event.phone);
        final response = await _supabase.auth.signInWithPassword(
          phone: formattedPhone,
          password: event.password,
        );

        if (response.user != null) {
          final successState = await _fetchProfileAndBuildSuccessState(
            response.user!,
          );
          if (successState != null) {
            await FcmHandler().registerCurrentDevice();
            emit(successState);
          } else {
            emit(AuthFailure('Không thể truy xuất thông tin người dùng.'));
          }
        } else {
          emit(AuthFailure('Không thể truy xuất thông tin người dùng.'));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        if (event.username.trim().isEmpty) {
          emit(AuthFailure('Tên người dùng không được để trống.'));
          return;
        }

        final formattedPhone = _formatPhoneNumber(event.phone);
        final functionResponse = await _supabase.functions.invoke(
          'create-profile-from-phone',
          body: {
            'phone': formattedPhone,
            'password': event.password,
            'username': event.username.trim(),
            'role': event.role.toUpperCase(),
          },
        );

        if (functionResponse.status != 200) {
          final serverError = functionResponse.data?['error']?.toString() ?? '';
          if (serverError.contains('phone_already_taken') ||
              serverError.contains('already registered')) {
            emit(AuthFailure('phone_already_taken'));
          } else {
            emit(AuthFailure('Đăng ký qua máy chủ không thành công.'));
          }
          return;
        }

        final loginResponse = await _supabase.auth.signInWithPassword(
          phone: formattedPhone,
          password: event.password,
        );

        if (loginResponse.user != null) {
          final successState = await _fetchProfileAndBuildSuccessState(
            loginResponse.user!,
            fallbackRole: event.role.toUpperCase(),
          );
          if (successState != null) {
            await FcmHandler().registerCurrentDevice();
            emit(successState);
          } else {
            emit(
              AuthFailure(
                'Đăng ký thành công nhưng không thể tự động đăng nhập.',
              ),
            );
          }
        } else {
          emit(
            AuthFailure(
              'Đăng ký thành công nhưng không thể tự động đăng nhập.',
            ),
          );
        }
      } on FunctionException catch (e) {
        final errorString = e.details?.toString() ?? '';
        if (errorString.contains('phone_already_taken') ||
            errorString.contains('already registered')) {
          emit(AuthFailure('phone_already_taken'));
        } else {
          emit(AuthFailure('Hệ thống đăng ký gặp lỗi. Vui lòng thử lại sau.'));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('Lỗi kết nối hệ thống trong quá trình đăng ký.'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _supabase.auth.signOut();
      } catch (_) {}
      emit(AuthInitial());
    });

    on<UpdateAvatarRequested>((event, emit) async {
      final currentState = state;
      if (currentState is! AuthSuccess) return;

      try {
        final file = File(event.imagePath);
        final fileExt = event.imagePath.split('.').last;
        final fileName =
            '${currentState.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = fileName;

        await _supabase.storage
            .from('profile_avatar')
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final String publicUrl = _supabase.storage
            .from('profile_avatar')
            .getPublicUrl(filePath);

        await _supabase
            .from('profiles')
            .update({'avatar_url': publicUrl})
            .eq('user_id', currentState.uid);

        emit(
          AuthSuccess(
            uid: currentState.uid,
            name: currentState.name,
            email: currentState.email,
            avatarPath: publicUrl,
            role: currentState.role,
          ),
        );
      } catch (e) {
        print('Error updating avatar: $e');
        emit(currentState);
      }
    });

    on<ForgotPasswordByPhoneRequested>(_handlePhoneResetRequest);

    on<ForgotPasswordPhoneConfirmed>(_handlePhoneResetConfirmation);

    on<ForgotPasswordByEmailRequested>(_handleEmailResetRequest);

    add(AppStarted());
  }

  Future<void> _handlePhoneResetRequest(
    ForgotPasswordByPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final formattedPhone = _formatPhoneNumber(event.phone);

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: false,
      );

      emit(AuthPasswordResetOtpSent());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Không thể gửi mã OTP. Vui lòng thử lại.'));
    }
  }

  Future<void> _handlePhoneResetConfirmation(
    ForgotPasswordPhoneConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final formattedPhone = _formatPhoneNumber(event.phone);

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: event.otpCode,
        type: OtpType.recovery,
      );

      if (response.user == null) {
        emit(AuthFailure('Mã OTP không đúng hoặc đã hết hạn.'));
        return;
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: event.newPassword),
      );

      await _supabase.auth.signOut();

      emit(AuthPasswordResetSuccess());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Không thể đổi mật khẩu.'));
    }
  }

  Future<void> _handleEmailResetRequest(
    ForgotPasswordByEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _supabase.auth.resetPasswordForEmail(
        event.email.trim(),
        redirectTo: 'brokerviet://password_reset',
      );

      emit(AuthPasswordResetEmailSent());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(AuthFailure('Không thể gửi liên kết đặt lại mật khẩu.'));
    }
  }
}
