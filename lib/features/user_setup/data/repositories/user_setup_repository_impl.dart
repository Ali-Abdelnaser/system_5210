import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/user_setup_repository.dart';
import '../../data/models/user_profile_model.dart';

class UserSetupRepositoryImpl implements UserSetupRepository {
  final FirebaseFirestore firestore;

  UserSetupRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, void>> saveUserProfile(
    UserProfileModel profile,
  ) async {
    try {
      // 1. Save to 'users' collection with the same UID
      await firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Right(UserProfileModel.fromMap(doc.data()!));
      } else {
        return const Left(FirebaseFailure("User profile not found"));
      }
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
