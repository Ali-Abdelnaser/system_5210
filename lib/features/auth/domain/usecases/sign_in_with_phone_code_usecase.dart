import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhoneCodeUseCase {
  final AuthRepository repository;

  SignInWithPhoneCodeUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String verificationId,
    required String smsCode,
  }) {
    return repository.signInWithPhoneCode(verificationId, smsCode);
  }
}
