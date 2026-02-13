import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/usecases/save_user_profile_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'user_setup_state.dart';

class UserSetupCubit extends Cubit<UserSetupState> {
  final SaveUserProfileUseCase _saveUserProfileUseCase;
  final FirebaseAuth _auth;

  UserSetupCubit({
    required SaveUserProfileUseCase saveUserProfileUseCase,
    required FirebaseAuth auth,
  }) : _saveUserProfileUseCase = saveUserProfileUseCase,
       _auth = auth,
       super(UserSetupInitial());

  String? _selectedRole;
  Map<String, dynamic> _quizAnswers = {};
  Map<String, dynamic>? _parentProfileData;
  String? _photoUrl;

  void reset() {
    _selectedRole = null;
    _quizAnswers = {};
    _parentProfileData = null;
    _photoUrl = null;
    emit(UserSetupInitial());
  }

  void selectRole(String role) {
    _selectedRole = role;
    emit(UserSetupRoleSelected(role));
  }

  void updateQuizAnswers(Map<String, dynamic> answers) {
    _quizAnswers.addAll(answers);
  }

  void updateParentProfile(Map<String, dynamic> data) {
    _parentProfileData = data;
  }

  Future<void> saveProfile({
    required Map<String, dynamic> parentProfileData,
    required Map<String, dynamic> answers,
    String? photoUrl,
  }) async {
    _parentProfileData = parentProfileData;
    _quizAnswers = answers;
    _photoUrl = photoUrl;
    _selectedRole ??= 'parent'; // Default to parent for profile editing
    await submitSetup();
  }

  /// Updates the user profile directly without relying on the wizard state.
  /// Use this for Edit Profile functionality.
  Future<void> updateUserProfile({
    required String uid,
    required String role,
    required Map<String, dynamic> parentProfileData,
    required Map<String, dynamic> quizAnswers,
    String? photoUrl,
    String? displayName,
    String? phoneNumber,
    String? email,
  }) async {
    emit(UserSetupLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const UserSetupFailure("User not logged in"));
        return;
      }

      // Use passed values, or fallback to current user values, or keep existing.
      // For photoUrl, if passed (even if different from auth), use it.
      // If null, we can fall back to auth photo, or keep null.
      // In Edit Profile, we pass the *current* profile's photoUrl.

      final profile = UserProfileModel(
        uid: uid,
        role: role,
        email: email ?? user.email,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        displayName: displayName ?? user.displayName,
        photoUrl: photoUrl ?? user.photoURL,
        quizAnswers: quizAnswers,
        parentProfile: parentProfileData,
        isSetupCompleted: true,
      );

      final result = await _saveUserProfileUseCase(profile);

      result.fold(
        (failure) => emit(UserSetupFailure(failure.message)),
        (_) => emit(UserSetupSuccess()),
      );
    } catch (e) {
      emit(UserSetupFailure(e.toString()));
    }
  }

  Future<void> submitSetup() async {
    emit(UserSetupLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const UserSetupFailure("User not logged in"));
        return;
      }

      // Ensure we have a role. If not, default or error.
      // But typically this method is called at the end of the flow.
      if (_selectedRole == null) {
        emit(const UserSetupFailure("Role not selected"));
        return;
      }

      final profile = UserProfileModel(
        uid: user.uid,
        role: _selectedRole!,
        email: user.email,
        phoneNumber: user.phoneNumber,
        displayName: _parentProfileData?['fullName'] ?? user.displayName,
        photoUrl: _photoUrl ?? user.photoURL,
        quizAnswers: _quizAnswers,
        parentProfile: _parentProfileData,
        isSetupCompleted: true,
      );

      final result = await _saveUserProfileUseCase(profile);

      result.fold(
        (failure) => emit(UserSetupFailure(failure.message)),
        (_) => emit(UserSetupSuccess()),
      );
    } catch (e) {
      emit(UserSetupFailure(e.toString()));
    }
  }
}
