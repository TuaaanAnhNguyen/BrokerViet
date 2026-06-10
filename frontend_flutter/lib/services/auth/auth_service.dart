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

          final profileUsername = profileData != null ? profileData['username'] : null;
          final profileRole = profileData != null ? profileData['role'] : null;
          final profileAvatar = profileData != null ? profileData['avatar_url'] : null;

          emit(
            AuthSuccess(
              uid: userId,
              name: profileUsername ?? response.user!.userMetadata?['username'] ?? 'Người dùng',
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
          emit(AuthFailure('Đăng ký qua máy chủ không thành công.'));
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
          emit(AuthFailure('Đăng ký thành công nhưng không thể tự động đăng nhập.'));
        }
      } on FunctionException catch (e) {
        emit(AuthFailure(e.details?.toString() ?? 'Lỗi không xác định khi gọi hàm đăng ký.'));
      } on AuthException catch (e) {
        emit(AuthFailure(e.message));
      } catch (e) {
        emit(AuthFailure('Lỗi kết nối hệ thống trong quá trình đăng ký.'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await _supabase.auth.signOut();
      } catch (_) {}
      emit(AuthInitial());
    });
  }
}