import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_5210/features/user_setup/data/models/user_profile_model.dart';
import 'package:system_5210/features/user_setup/domain/usecases/get_user_profile_usecase.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final AuthRepository authRepository;

  HomeCubit({required this.getUserProfileUseCase, required this.authRepository})
    : super(HomeInitial());

  Future<void> loadUserProfile() async {
    emit(HomeLoading());
    try {
      final userOption = await authRepository.getCurrentUser();
      userOption.fold(() => emit(const HomeFailure("User not logged in")), (
        user,
      ) async {
        final result = await getUserProfileUseCase(user.uid);
        result.fold((failure) => emit(HomeFailure(failure.message)), (profile) {
          String name = "Hero";
          if (profile.role == 'parent' && profile.parentProfile != null) {
            name = profile.parentProfile!['fullName'] ?? "Hero";
          } else if (profile.role == 'child') {
            // If checking for child name specifically, we might look into answers or auth displayName
            // Child quiz doesn't explicitly ask for "Name", so we fallback to Auth displayName or "Hero"
            name = user.displayName ?? "Hero";
          } else {
            name = user.displayName ?? "Hero";
          }
          emit(HomeLoaded(displayName: name, userProfile: profile));
        });
      });
    } catch (e) {
      emit(HomeFailure(e.toString()));
    }
  }
}
