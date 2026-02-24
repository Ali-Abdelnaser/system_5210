import 'package:bloc/bloc.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_5210/features/user_setup/domain/usecases/get_user_profile_usecase.dart';
import 'package:system_5210/core/services/storage_service.dart';
import 'package:system_5210/features/user_setup/domain/repositories/user_setup_repository.dart';
import 'dart:io';
import 'package:system_5210/features/user_setup/data/models/user_profile_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final AuthRepository authRepository;
  final StorageService storageService;
  final UserSetupRepository userSetupRepository;

  ProfileCubit({
    required this.getUserProfileUseCase,
    required this.authRepository,
    required this.storageService,
    required this.userSetupRepository,
  }) : super(ProfileInitial());

  void reset() {
    emit(ProfileInitial());
  }

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final userOption = await authRepository.getCurrentUser();

      await userOption.fold(
        () async => emit(const ProfileFailure("User not logged in")),
        (user) async {
          final result = await getUserProfileUseCase(user.uid);
          result.fold(
            (failure) => emit(ProfileFailure(failure.message)),
            (profile) => emit(ProfileLoaded(profile)),
          );
        },
      );
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    UserProfileModel? currentProfile;
    if (state is ProfileLoaded) {
      currentProfile = (state as ProfileLoaded).profile;
    } else if (state is ProfileUploading) {
      currentProfile = (state as ProfileUploading).profile;
    }

    if (currentProfile == null) return;

    try {
      // 1. Upload to Storage with progress
      final downloadUrl = await storageService.uploadProfileImage(
        uid: currentProfile.uid,
        imageFile: imageFile,
        onProgress: (progress) {
          emit(ProfileUploading(currentProfile!, progress));
        },
      );

      // 2. Update Profile Model
      final updatedProfile = currentProfile.copyWith(photoUrl: downloadUrl);

      // 3. Save to Firestore
      final result = await userSetupRepository.saveUserProfile(updatedProfile);

      await result.fold(
        (failure) async => emit(ProfileFailure(failure.message)),
        (_) async {
          // Show success animation state
          emit(ProfileUploadSuccess(updatedProfile));
          // Wait for animation to finish
          await Future.delayed(const Duration(seconds: 2));
          emit(ProfileLoaded(updatedProfile));
        },
      );
    } catch (e) {}
  }

  Future<void> updateBioData({
    required double height,
    required double weight,
    required int age,
  }) async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    try {
      // We'll store these in quizAnswers or a custom map.
      // For now, let's update quizAnswers since it's already supported in the model.
      final updatedQuiz = Map<String, dynamic>.from(currentProfile.quizAnswers);
      updatedQuiz['height'] = height;
      updatedQuiz['weight'] = weight;
      updatedQuiz['age'] = age;

      final updatedProfile = currentProfile.copyWith(quizAnswers: updatedQuiz);

      emit(ProfileLoading());
      final result = await userSetupRepository.saveUserProfile(updatedProfile);

      result.fold(
        (failure) => emit(ProfileFailure(failure.message)),
        (_) => emit(ProfileLoaded(updatedProfile)),
      );
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
