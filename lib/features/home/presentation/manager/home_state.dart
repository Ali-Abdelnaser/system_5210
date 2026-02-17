part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  // Note: userProfile field in HomeLoaded requires UserProfileModel imported in the main part file or here part of relationship handles it?
  // Since it's a part file, it shares imports with home_cubit.dart.
  // Wait, UserProfileModel is used in HomeLoaded but imports are in home_cubit.dart. That should be fine if it's "part of".
  // But let's check if the linter complained. YES: "Undefined class 'UserProfileModel'".
  // Actually, 'part of' files share the scope of the parent file. So imports in parent are available here.
  // The linter error for HomeState might be because I created it separately and the parent didn't have correct imports *at that time*.
  // I just fixed imports in home_cubit.dart. So HomeState should be fine now.
  // I will just return clean content to be safe.

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String displayName;
  final UserProfileModel userProfile;
  final Map<String, dynamic>? streakResult;

  const HomeLoaded({
    required this.displayName,
    required this.userProfile,
    this.streakResult,
  });

  @override
  List<Object?> get props => [displayName, userProfile, streakResult];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
