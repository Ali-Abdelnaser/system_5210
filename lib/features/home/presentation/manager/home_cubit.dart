import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:five2ten/features/user_setup/data/models/user_profile_model.dart';
import 'package:five2ten/features/user_setup/domain/usecases/get_user_profile_usecase.dart';
import 'package:five2ten/features/auth/domain/repositories/auth_repository.dart';

import 'package:five2ten/features/specialists/domain/entities/doctor.dart';
import 'package:five2ten/features/specialists/domain/usecases/get_specialists.dart';
import 'package:five2ten/core/services/streak_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetSpecialists getSpecialists;
  final AuthRepository authRepository;
  final StreakService streakService;

  HomeCubit({
    required this.getUserProfileUseCase,
    required this.getSpecialists,
    required this.authRepository,
    required this.streakService,
  }) : super(HomeInitial());

  Future<void> loadUserProfile() async {
    emit(HomeLoading());
    try {
      final userOption = await authRepository.getCurrentUser();
      userOption.fold(() => emit(const HomeFailure("User not logged in")), (
        user,
      ) async {
        // Fetch Profile and Specialists in parallel for speed
        final results = await Future.wait([
          getUserProfileUseCase(user.uid),
          getSpecialists(),
        ]);

        final profileResult =
            results[0] as dynamic; // Either<Failure, UserProfileModel>
        final specialistsResult =
            results[1] as dynamic; // Either<Failure, List<Doctor>>

        profileResult.fold((failure) => emit(HomeFailure(failure.message)), (
          profile,
        ) async {
          // 1. Check and Update Streak
          final streakResult = await streakService.checkAndUpdateStreak(
            profile,
          );

          // 2. Refresh profile after streak update
          final refreshedResult = await getUserProfileUseCase(user.uid);

          // 3. Extract specialists (Don't fail the whole page if specialists fail)
          final List<Doctor> specialists = specialistsResult.fold((f) {
            debugPrint("Specialists Load Warning: ${f.message}");
            return [];
          }, (s) => s);

          refreshedResult.fold((f) => emit(HomeFailure(f.message)), (
            refreshedProfile,
          ) {
            String name = "Hero";
            if (refreshedProfile.role == 'parent' &&
                refreshedProfile.parentProfile != null) {
              name = refreshedProfile.parentProfile!['fullName'] ?? "Hero";
            } else {
              name = user.displayName ?? refreshedProfile.displayName ?? "Hero";
            }

            emit(
              HomeLoaded(
                displayName: name,
                userProfile: refreshedProfile,
                specialists: specialists, // Pre-fetched during splash!
                streakResult: streakResult,
              ),
            );
          });
        });
      });
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }
}
