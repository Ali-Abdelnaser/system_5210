import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String name,
  );
  Future<UserModel> loginWithGoogle();

  /// Sends SMS OTP to [phoneNumber] (E.164 format, e.g. +201234567890).
  /// Returns [verificationId] when code is sent; use it in [signInWithPhoneCode].
  Future<String> sendPhoneVerificationCode(String phoneNumber);

  /// Completes phone sign-in (login or register) using OTP.
  Future<UserModel> signInWithPhoneCode(String verificationId, String smsCode);

  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> checkUserDataExists(String uid);
  Future<bool> checkPhoneNumberExists(String phoneNumber);
  Future<bool> checkEmailExists(String email);
  Future<void> updateDisplayName(String name);
  Future<void> forgotPassword(String email);
  Future<void> verifyPasswordResetOTP(String email, String code);
  Future<void> resetPassword(String email, String newPassword);
  Future<void> sendEmailVerificationOTP(String email, {String? name});
  Future<void> verifyEmailOTP(String email, String code);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> updateEmail(String currentPassword, String newEmail);
}
