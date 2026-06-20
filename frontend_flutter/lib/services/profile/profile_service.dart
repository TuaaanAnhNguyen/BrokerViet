// lib/services/profile/profile_service.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile_model.dart';

abstract class ProfileEvent {}

class LoadProfileRequested extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final ProfileModel updatedProfile;
  UpdateProfileRequested(this.updatedProfile);
}

class UpdatePasswordRequested extends ProfileEvent {
  final String newPassword;
  UpdatePasswordRequested({required this.newPassword});
}

class UpdateEmailRequested extends ProfileEvent {
  final String newEmail;
  UpdateEmailRequested(this.newEmail);
}

class DeleteAccountRequested extends ProfileEvent {}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileActionLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final ProfileModel profile;
  ProfileLoadSuccess(this.profile);
}

class ProfileActionSuccess extends ProfileState {
  final String successMessage;
  ProfileActionSuccess(this.successMessage);
}

class ProfileFailure extends ProfileState {
  final String errorMessage;
  ProfileFailure(this.errorMessage);
}

class ProfileService extends Bloc<ProfileEvent, ProfileState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  ProfileService() : super(ProfileInitial()) {
    on<LoadProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser == null) throw Exception("Chưa đăng nhập hệ thống.");

        final data = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', currentUser.id)
            .single();

        final profile = ProfileModel.fromJson(
          data,
          authEmail: currentUser.email,
          authPhone: currentUser.phone,
        );

        emit(ProfileLoadSuccess(profile));
      } catch (e) {
        emit(ProfileFailure('Không thể tải thông tin: ${e.toString()}'));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      emit(ProfileActionLoading());
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) throw Exception("Phiên đăng nhập hết hạn.");

        final updateData = event.updatedProfile.toUpdatePayload();

        await _supabase
            .from('profiles')
            .update(updateData)
            .eq('user_id', userId);

        emit(ProfileActionSuccess('Cập nhật hồ sơ thành công!'));

        add(LoadProfileRequested());
      } catch (e) {
        emit(ProfileFailure('Lỗi cập nhật dữ liệu: ${e.toString()}'));
      }
    });

    on<UpdatePasswordRequested>((event, emit) async {
      emit(ProfileActionLoading());
      try {
        await _supabase.auth.updateUser(
          UserAttributes(password: event.newPassword),
        );
        emit(ProfileActionSuccess('Cập nhật mật khẩu bảo mật mới thành công!'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateEmailRequested>((event, emit) async {
      emit(ProfileActionLoading());
      try {
        await _supabase.auth.updateUser(UserAttributes(email: event.newEmail));
        emit(
          ProfileActionSuccess(
            'Liên kết xác thực đã được gửi tới hộp thư mới!',
          ),
        );
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<DeleteAccountRequested>((event, emit) async {
      emit(ProfileActionLoading());
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          await _supabase.from('profiles').delete().eq('user_id', userId);
        }
        await _supabase.auth.signOut();
        emit(ProfileActionSuccess('Tài khoản đã được gỡ bỏ hoàn toàn.'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}
