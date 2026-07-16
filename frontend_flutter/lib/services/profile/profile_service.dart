// lib/services/profile/profile_service.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile_model.dart';
import '../map-location/location_service.dart';

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

class ProfileActionLoading extends ProfileLoadSuccess {
  ProfileActionLoading(super.profile);
}

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
  final SupabaseClient _client = Supabase.instance.client;
  final LocationService _locationService = LocationService();

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  ProfileService() : super(ProfileInitial()) {
    on<LoadProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        if (currentUserId.isEmpty) throw Exception("Chưa đăng nhập hệ thống.");

        final response = await _client.functions.invoke('fetch-profile');

        if (response.status != 200) {
          final errorData = response.data as Map<String, dynamic>?;
          throw Exception(
            errorData?['error'] ?? 'Lỗi không xác định từ Edge Function',
          );
        }

        final dataMap = response.data as Map<String, dynamic>;
        final profileData = dataMap['profile'];

        if (profileData == null) {
          throw Exception("Không tìm thấy thông tin hồ sơ người dùng.");
        }

        final profile = ProfileModel.fromJson(
          profileData as Map<String, dynamic>,
          authEmail: _client.auth.currentUser?.email,
          authPhone: _client.auth.currentUser?.phone,
        );

        emit(ProfileLoadSuccess(profile));
      } catch (e) {
        emit(ProfileFailure('Không thể tải thông tin: ${e.toString()}'));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      if (state is ProfileLoadSuccess) {
        emit(ProfileActionLoading((state as ProfileLoadSuccess).profile));
      }

      try {
        if (currentUserId.isEmpty) {
          throw Exception("Phiên đăng nhập hết hạn.");
        }

        ProfileModel profileToSave = event.updatedProfile;

        final address = profileToSave.address?.trim();

        // If user entered an address, convert it into coordinates first.
        if (address != null && address.isNotEmpty) {
          final geocoded = await _locationService.geocodeAddress(
            address: address,
          );

          profileToSave = profileToSave.copyWith(
            address: geocoded.displayName,
            locationText: geocoded.displayName,
            locationLatitude: geocoded.latitude,
            locationLongitude: geocoded.longitude,
          );
        }

        final response = await _client.functions.invoke(
          'update-profile',
          body: profileToSave.toUpdatePayload(),
        );

        if (response.status != 200) {
          final errorData = response.data as Map<String, dynamic>?;

          throw Exception(
            errorData?['error'] ?? 'Lỗi không thể cập nhật dữ liệu',
          );
        }

        emit(ProfileActionSuccess('Cập nhật hồ sơ thành công!'));

        add(LoadProfileRequested());
      } catch (e, stack) {
        print("========== PROFILE UPDATE ERROR ==========");
        print(e);
        print(stack);

        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdatePasswordRequested>((event, emit) async {
      if (state is ProfileLoadSuccess) {
        emit(ProfileActionLoading((state as ProfileLoadSuccess).profile));
      }
      try {
        await _client.auth.updateUser(
          UserAttributes(password: event.newPassword),
        );
        emit(ProfileActionSuccess('Cập nhật mật khẩu bảo mật mới thành công!'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateEmailRequested>((event, emit) async {
      if (state is ProfileLoadSuccess) {
        emit(ProfileActionLoading((state as ProfileLoadSuccess).profile));
      }

      try {
        await _client.auth.updateUser(
          UserAttributes(email: event.newEmail.trim()),
        );

        emit(
          ProfileActionSuccess(
            "Đã gửi email xác thực. Vui lòng kiểm tra hộp thư.",
          ),
        );

        add(LoadProfileRequested());
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<DeleteAccountRequested>((event, emit) async {
      if (state is ProfileLoadSuccess) {
        emit(ProfileActionLoading((state as ProfileLoadSuccess).profile));
      }
      try {
        if (currentUserId.isNotEmpty) {
          final response = await _client.functions.invoke('delete-profile');
          if (response.status != 200) {
            final errorData = response.data as Map<String, dynamic>?;
            throw Exception(
              errorData?['error'] ??
                  'Lỗi không thể xóa tài khoản khỏi hệ thống',
            );
          }
        }
        await _client.auth.signOut();
        emit(ProfileActionSuccess('Tài khoản đã được gỡ bỏ hoàn toàn.'));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}
