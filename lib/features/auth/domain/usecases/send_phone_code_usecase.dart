import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendPhoneCodeUseCase {
  final AuthRepository repository;

  SendPhoneCodeUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) {
    return repository.sendPhoneVerificationCode(phoneNumber);
  }
}
