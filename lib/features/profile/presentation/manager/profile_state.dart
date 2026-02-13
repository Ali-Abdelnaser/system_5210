import 'package:equatable/equatable.dart';
import 'package:system_5210/features/user_setup/data/models/user_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUploading extends ProfileState {
  final UserProfileModel profile;
  final double progress;
  const ProfileUploading(this.profile, this.progress);

  @override
  List<Object?> get props => [profile, progress];
}

class ProfileUploadSuccess extends ProfileState {
  final UserProfileModel profile;
  const ProfileUploadSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
