import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import '../../data/models/user_profile_model.dart';

abstract class UserSetupRepository {
  Future<Either<Failure, void>> saveUserProfile(UserProfileModel profile);
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid);
}
