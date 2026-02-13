import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/user_setup_repository.dart';

class GetUserProfileUseCase {
  final UserSetupRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileModel>> call(String uid) async {
    return await repository.getUserProfile(uid);
  }
}
