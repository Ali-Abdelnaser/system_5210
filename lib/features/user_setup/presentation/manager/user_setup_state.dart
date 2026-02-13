part of 'user_setup_cubit.dart';

abstract class UserSetupState extends Equatable {
  const UserSetupState();

  @override
  List<Object> get props => [];
}

class UserSetupInitial extends UserSetupState {}

class UserSetupRoleSelected extends UserSetupState {
  final String role;
  const UserSetupRoleSelected(this.role);

  @override
  List<Object> get props => [role];
}

class UserSetupLoading extends UserSetupState {}

class UserSetupSuccess extends UserSetupState {}

class UserSetupFailure extends UserSetupState {
  final String message;
  const UserSetupFailure(this.message);

  @override
  List<Object> get props => [message];
}
