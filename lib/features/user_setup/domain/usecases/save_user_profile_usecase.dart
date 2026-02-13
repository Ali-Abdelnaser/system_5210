import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/user_setup_repository.dart';

class SaveUserProfileUseCase {
  final UserSetupRepository repository;

  SaveUserProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(UserProfileModel profile) async {
    return await repository.saveUserProfile(profile);
  }
}
