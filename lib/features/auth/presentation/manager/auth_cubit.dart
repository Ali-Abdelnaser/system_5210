import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_social_usecase.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/send_phone_code_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_code_usecase.dart';
import '../../domain/usecases/check_user_data_exists_usecase.dart';
import '../../domain/usecases/check_phone_registered_usecase.dart';
import '../../domain/usecases/update_display_name_usecase.dart';
import '../../domain/usecases/check_email_exists_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_password_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_email_verification_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/update_email_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'package:system_5210/core/network/network_info.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final RegisterWithEmailUseCase registerWithEmailUseCase;
  final LoginWithSocialUseCase loginWithSocialUseCase;
  final SendPhoneCodeUseCase sendPhoneCodeUseCase;
  final SignInWithPhoneCodeUseCase signInWithPhoneCodeUseCase;
  final CheckUserDataExistsUseCase checkUserDataExistsUseCase;
  final CheckPhoneRegisteredUseCase checkPhoneRegisteredUseCase;
  final UpdateDisplayNameUseCase updateDisplayNameUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckEmailExistsUseCase checkEmailExistsUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyPasswordResetOTPUseCase verifyPasswordResetOTPUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SendEmailVerificationOTPUseCase sendEmailVerificationOTPUseCase;
  final VerifyEmailOTPUseCase verifyEmailOTPUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final UpdateEmailUseCase updateEmailUseCase;
  final NetworkInfo networkInfo;

  String? _pendingDisplayName;

  AuthCubit({
    required this.loginWithEmailUseCase,
    required this.registerWithEmailUseCase,
    required this.loginWithSocialUseCase,
    required this.sendPhoneCodeUseCase,
    required this.signInWithPhoneCodeUseCase,
    required this.checkUserDataExistsUseCase,
    required this.checkPhoneRegisteredUseCase,
    required this.updateDisplayNameUseCase,
    required this.logoutUseCase,
    required this.checkEmailExistsUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyPasswordResetOTPUseCase,
    required this.resetPasswordUseCase,
    required this.sendEmailVerificationOTPUseCase,
    required this.verifyEmailOTPUseCase,
    required this.updatePasswordUseCase,
    required this.updateEmailUseCase,
    required this.networkInfo,
  }) : super(AuthInitial());

  void setPendingDisplayName(String name) {
    _pendingDisplayName = name;
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await loginWithEmailUseCase(
      email: email,
      password: password,
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) async {
      // If login with email, check if verified
      if (user.phoneNumber == null && !user.isEmailVerified) {
        emit(AuthEmailVerificationSent());
        return;
      }

      final existsResult = await checkUserDataExistsUseCase(user.uid);
      existsResult.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (exists) => emit(AuthSuccess(user, dataExists: exists)),
      );
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await registerWithEmailUseCase(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthEmailVerificationSent()),
    );
  }

  Future<void> socialLogin(SocialType type) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await loginWithSocialUseCase(type);
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) async {
      final existsResult = await checkUserDataExistsUseCase(user.uid);
      existsResult.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (exists) => emit(AuthSuccess(user, dataExists: exists)),
      );
    });
  }

  /// Sends OTP for login; checks if phone is registered first.
  Future<void> sendPhoneVerificationForLogin(String phoneNumber) async {
    emit(AuthLoading());
    final checkResult = await checkPhoneRegisteredUseCase(phoneNumber);

    await checkResult.fold(
      (failure) async => emit(AuthFailure(failure.message)),
      (isRegistered) async {
        if (!isRegistered) {
          emit(
            const AuthFailure(
              "This phone number is not registered. Please create an account first.",
            ),
          );
        } else {
          final result = await sendPhoneCodeUseCase(phoneNumber);
          result.fold(
            (failure) => emit(AuthFailure(failure.message)),
            (verificationId) => emit(AuthPhoneCodeSent(verificationId)),
          );
        }
      },
    );
  }

  /// Sends OTP to phone; on success emits [AuthPhoneCodeSent] with verificationId.
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await sendPhoneCodeUseCase(phoneNumber);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (verificationId) => emit(AuthPhoneCodeSent(verificationId)),
    );
  }

  /// Completes phone sign-in with OTP.
  Future<void> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await signInWithPhoneCodeUseCase(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) async {
      // If there is a pending name from registration, update the Firebase user profile
      if (_pendingDisplayName != null) {
        final updateResult = await updateDisplayNameUseCase(
          _pendingDisplayName!,
        );
        updateResult.fold(
          (failure) => null, // Non-critical error, continue to dashboard
          (_) => _pendingDisplayName = null,
        );
      }

      final existsResult = await checkUserDataExistsUseCase(user.uid);
      existsResult.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (exists) => emit(AuthSuccess(user, dataExists: exists)),
      );
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> checkEmailVerificationStatus() async {
    emit(AuthLoading());
    // Get current user model
    final userOption = await loginWithSocialUseCase.repository.getCurrentUser();

    await userOption.fold(
      () async =>
          emit(const AuthFailure("Session expired. Please login again.")),
      (user) async {
        // Since we need to refresh from Firebase, we call a reload at data source level
        // For simplicity here, we assume remote data source already reloads on getCurrentUser
        // or we add a specific refresh method.
        // Let's use the current user from repository which we'll update to reload.
        if (user.isEmailVerified) {
          final existsResult = await checkUserDataExistsUseCase(user.uid);
          existsResult.fold(
            (failure) => emit(AuthFailure(failure.message)),
            (exists) => emit(AuthSuccess(user, dataExists: exists)),
          );
        } else {
          emit(
            const AuthFailure(
              "Email not verified yet. Please check your inbox.",
            ),
          );
        }
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    // 1. Check if email exists
    final checkResult = await checkEmailExistsUseCase(email);

    await checkResult.fold(
      (failure) async => emit(AuthFailure(failure.message)),
      (exists) async {
        if (!exists) {
          emit(
            const AuthFailure(
              "This email is not registered. Please create an account first.",
            ),
          );
        } else {
          // 2. Send reset email
          final result = await forgotPasswordUseCase(email);
          result.fold(
            (failure) => emit(AuthFailure(failure.message)),
            (_) => emit(AuthPasswordResetSent()),
          );
        }
      },
    );
  }

  Future<void> verifyPasswordResetOTP({
    required String email,
    required String code,
  }) async {
    emit(AuthLoading());
    final result = await verifyPasswordResetOTPUseCase(
      email: email,
      code: code,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthPasswordResetVerified()),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(
      email: email,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthPasswordResetSuccess()),
    );
  }

  Future<void> sendEmailVerificationOTP(String email, {String? name}) async {
    emit(AuthLoading());
    final result = await sendEmailVerificationOTPUseCase(email, name: name);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthEmailVerificationSent()),
    );
  }

  Future<void> verifyEmailOTP({
    required String email,
    required String code,
  }) async {
    emit(AuthLoading());
    if (!await networkInfo.isConnected) {
      emit(
        const AuthFailure(
          "No internet connection. Please check your network and try again.",
        ),
      );
      return;
    }
    final result = await verifyEmailOTPUseCase(email: email, code: code);
    result.fold((failure) => emit(AuthFailure(failure.message)), (_) async {
      emit(AuthEmailVerificationVerified());
      // After verification, check if user data exists to proceed
      final userOption = await loginWithSocialUseCase.repository
          .getCurrentUser();
      userOption.fold(() => emit(const AuthFailure("Session expired.")), (
        user,
      ) async {
        final existsResult = await checkUserDataExistsUseCase(user.uid);
        existsResult.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (exists) => emit(AuthSuccess(user, dataExists: exists)),
        );
      });
    });
  }

  Future<void> updatePasswordSettings({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await updatePasswordUseCase(
      UpdatePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUpdateSuccess("Password updated successfully")),
    );
  }

  Future<void> updateEmailSettings({
    required String currentPassword,
    required String newEmail,
  }) async {
    emit(AuthLoading());
    final result = await updateEmailUseCase(
      UpdateEmailParams(currentPassword: currentPassword, newEmail: newEmail),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(
        AuthUpdateSuccess(
          "Email verification sent to $newEmail. Please verify to complete update.",
        ),
      ),
    );
  }
}
