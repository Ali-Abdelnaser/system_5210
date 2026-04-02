import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final bool dataExists;

  const AuthSuccess(this.user, {this.dataExists = true});

  @override
  List<Object?> get props => [user, dataExists];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// OTP was sent to phone; navigate to verification screen with [verificationId].
class AuthPhoneCodeSent extends AuthState {
  final String verificationId;
  const AuthPhoneCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

/// Email verification link was sent after registration; show confirmation page.
class AuthEmailVerificationSent extends AuthState {}

/// Email OTP was resent from verification screen; do not push another route.
class AuthEmailOtpResent extends AuthState {}

/// Phone OTP was resent; includes new [verificationId] for the same screen.
class AuthPhoneOtpResent extends AuthState {
  final String verificationId;
  const AuthPhoneOtpResent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthEmailVerificationVerified extends AuthState {}

class AuthPasswordResetSent extends AuthState {}

class AuthPasswordResetVerified extends AuthState {}

class AuthPasswordResetSuccess extends AuthState {}

class AuthUpdateSuccess extends AuthState {
  final String message;
  const AuthUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class Unauthenticated extends AuthState {}
