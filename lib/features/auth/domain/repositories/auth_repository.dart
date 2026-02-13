import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity>> loginWithGoogle();

  /// Sends OTP to phone; returns verificationId for the verification screen.
  Future<Either<Failure, String>> sendPhoneVerificationCode(String phoneNumber);

  /// Completes phone sign-in with OTP.
  Future<Either<Failure, UserEntity>> signInWithPhoneCode(
    String verificationId,
    String smsCode,
  );

  Future<Either<Failure, void>> logout();
  Future<Option<UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> checkUserDataExists(String uid);
  Future<Either<Failure, bool>> checkPhoneNumberExists(String phoneNumber);
  Future<Either<Failure, bool>> checkEmailExists(String email);
  Future<Either<Failure, void>> updateDisplayName(String name);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> verifyPasswordResetOTP(
    String email,
    String code,
  );
  Future<Either<Failure, void>> resetPassword(String email, String newPassword);
  Future<Either<Failure, void>> sendEmailVerificationOTP(
    String email, {
    String? name,
  });
  Future<Either<Failure, void>> verifyEmailOTP(String email, String code);
  Future<Either<Failure, void>> updatePassword(
    String currentPassword,
    String newPassword,
  );
  Future<Either<Failure, void>> updateEmail(
    String currentPassword,
    String newEmail,
  );
}
