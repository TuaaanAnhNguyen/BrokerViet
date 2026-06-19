// lib/services/auth/auth_service.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPasswordResetOtpSent extends AuthState {}

class AuthPasswordResetSuccess extends AuthState {}

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

class PasswordResetRequested extends AuthEvent {
  final String phone;
  PasswordResetRequested(this.phone);
}

class PasswordResetConfirmed extends AuthEvent {
  final String phone;
  final String otpCode;
  final String newPassword;
  PasswordResetConfirmed(this.phone, this.otpCode, this.newPassword);
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

  AuthService() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final formattedPhone = _formatPhoneNumber(event.phone);

        final response = await _supabase.auth.signInWithPassword(
          phone: formattedPhone,
          password: event.password,
        );

        if (response.user != null) {
          final userId = response.user!.id;

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

          emit(
            AuthSuccess(
              uid: userId,
              name:
                  profileUsername ??
                  response.user!.userMetadata?['username'] ??
                  'Người dùng',
              email: response.user!.email ?? '',
              avatarPath: profileAvatar ?? 'assets/default_profile.png',
              memberTier: profileRole ?? 'Thành viên',
            ),
          );
        } else {
          emit(AuthFailure('Không thể truy xuất thông tin người dùng.'));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('Số điện thoại hoặc mật khẩu không chính xác.'));
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
          emit(
            AuthSuccess(
              uid: loginResponse.user!.id,
              name: event.username.trim(),
              email: loginResponse.user!.email ?? '',
              avatarPath: 'assets/default_profile.png',
              memberTier: 'Thành viên',
            ),
          );
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

        // 1. Upload to Storage
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

        // 2. Get Public URL
        final String publicUrl = _supabase.storage
            .from('profile_avatar')
            .getPublicUrl(filePath);

        // 3. Update profiles table
        await _supabase
            .from('profiles')
            .update({'avatar_url': publicUrl})
            .eq('user_id', currentState.uid);

        // 4. Emit updated state
        emit(
          AuthSuccess(
            uid: currentState.uid,
            name: currentState.name,
            email: currentState.email,
            avatarPath: publicUrl,
            memberTier: currentState.memberTier,
          ),
        );
      } catch (e) {
        print('Error updating avatar: $e');
        emit(currentState);
      }
    });

    on<PasswordResetRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final formattedPhone = _formatPhoneNumber(event.phone);

        await _supabase.auth.signInWithOtp(phone: formattedPhone);

        emit(AuthPasswordResetOtpSent());
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (_) {
        emit(AuthFailure('Không thể gửi mã xác thực. Vui lòng thử lại.'));
      }
    });

    on<PasswordResetConfirmed>((event, emit) async {
      emit(AuthLoading());
      try {
        final formattedPhone = _formatPhoneNumber(event.phone);

        final response = await _supabase.auth.verifyOTP(
          phone: formattedPhone,
          token: event.otpCode,
          type: OtpType.sms,
        );

        if (response.user != null) {
          await _supabase.auth.updateUser(
            UserAttributes(password: event.newPassword),
          );

          await _supabase.auth.signOut();

          emit(AuthPasswordResetSuccess());
        } else {
          emit(AuthFailure('Mã xác thực không chính xác.'));
        }
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (_) {
        emit(AuthFailure('Đổi mật khẩu thất bại. Vui lòng thử lại.'));
      }
    });
  }
}
