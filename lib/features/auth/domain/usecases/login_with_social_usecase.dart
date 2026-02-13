import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

enum SocialType { google }

class LoginWithSocialUseCase {
  final AuthRepository repository;

  LoginWithSocialUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(SocialType type) {
    return repository.loginWithGoogle();
  }
}
