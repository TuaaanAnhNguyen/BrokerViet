// lib/services/auth/firebase_phone_auth_service.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthService {
  FirebasePhoneAuthService._();

  static final FirebasePhoneAuthService instance = FirebasePhoneAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;
  DateTime? _lastOtpSentTime;

  FirebaseAuth get auth => _auth;
  String? get currentVerificationId => _verificationId;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onVerificationFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (_lastOtpSentTime != null) {
      final difference = DateTime.now().difference(_lastOtpSentTime!);
      if (difference.inSeconds < 60) {
        final remaining = 60 - difference.inSeconds;
        onVerificationFailed(
          'Vui lòng đợi $remaining giây trước khi yêu cầu gửi lại mã mới.',
        );
        return;
      }
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(translateFirebaseError(e));
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _lastOtpSentTime = DateTime.now();
          onCodeSent();
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onVerificationFailed(
        'Không thể khởi tạo tiến trình gửi SMS. Vui lòng thử lại.',
      );
    }
  }

  Future<bool> verifyOtp({required String smsCode}) async {
    if (_verificationId == null) {
      throw Exception(
        'Phiên xác thực đã hết hạn hoặc không hợp lệ. Vui lòng gửi lại mã.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user != null;
  }

  Future<void> clearSession() async {
    _verificationId = null;
    _resendToken = null;
    _lastOtpSentTime = null;
    await _auth.signOut();
  }

  String translateFirebaseError(FirebaseAuthException e) {
    print("Firebase Auth Error Code: ${e.code}");
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Mã OTP không chính xác. Vui lòng kiểm tra và nhập lại.';
      case 'invalid-verification-id':
        return 'Phiên xác thực không hợp lệ hoặc đã hết hạn. Vui lòng gửi lại mã.';
      case 'session-expired':
        return 'Mã OTP đã hết hạn sử dụng. Vui lòng yêu cầu gửi lại mã mới.';
      case 'quota-exceeded':
        return 'Hệ thống tạm thời hết lượt gửi SMS miễn phí hôm nay. Vui lòng thử lại sau.';
      case 'invalid-phone-number':
        return 'Số điện thoại không đúng định dạng.';
      case 'user-disabled':
        return 'Tài khoản liên kết với số điện thoại này đã bị khóa.';
      case 'too-many-requests':
        return 'Thao tác quá nhanh và nhiều lần. Vui lòng thử lại sau vài phút.';
      default:
        return e.message ?? 'Đã xảy ra lỗi xác thực từ hệ thống.';
    }
  }
}
