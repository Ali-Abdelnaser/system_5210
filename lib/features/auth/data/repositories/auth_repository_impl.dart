import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/auth/domain/entities/user_entity.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_5210/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  static String _messageFromError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Wrong password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'too-many-requests':
          return 'Access from this device has been temporarily blocked due to unusual activity. Please try again later.';
        case 'invalid-phone-number':
          return 'Invalid phone number. Use country code (e.g. +20).';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.';
        default:
          return e.message ?? e.code;
      }
    }
    // Fallback for non-FirebaseAuthException
    if (e.toString().contains("blocked all requests")) {
      return 'Access from this device has been temporarily blocked due to unusual activity. Please try again later.';
    }
    return e.toString();
  }

  @override
  Future<Either<Failure, String>> sendPhoneVerificationCode(
    String phoneNumber,
  ) async {
    try {
      final verificationId = await remoteDataSource.sendPhoneVerificationCode(
        phoneNumber,
      );
      return Right(verificationId);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithPhoneCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final user = await remoteDataSource.signInWithPhoneCode(
        verificationId,
        smsCode,
      );
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await remoteDataSource.registerWithEmail(
        email,
        password,
        name,
      );
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final user = await remoteDataSource.loginWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        return some(user);
      }
      return none();
    } catch (_) {
      return none();
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserDataExists(String uid) async {
    try {
      final exists = await remoteDataSource.checkUserDataExists(uid);
      return Right(exists);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneNumberExists(
    String phoneNumber,
  ) async {
    try {
      final exists = await remoteDataSource.checkPhoneNumberExists(phoneNumber);
      return Right(exists);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplayName(String name) async {
    try {
      await remoteDataSource.updateDisplayName(name);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      final exists = await remoteDataSource.checkEmailExists(email);
      return Right(exists);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPasswordResetOTP(
    String email,
    String code,
  ) async {
    try {
      await remoteDataSource.verifyPasswordResetOTP(email, code);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(email, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerificationOTP(
    String email, {
    String? name,
  }) async {
    try {
      await remoteDataSource.sendEmailVerificationOTP(email, name: name);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOTP(
    String email,
    String code,
  ) async {
    try {
      await remoteDataSource.verifyEmailOTP(email, code);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.updatePassword(currentPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail(
    String currentPassword,
    String newEmail,
  ) async {
    try {
      await remoteDataSource.updateEmail(currentPassword, newEmail);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(_messageFromError(e)));
    }
  }
}
