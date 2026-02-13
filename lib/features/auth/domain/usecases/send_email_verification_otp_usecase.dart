import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationOTPUseCase {
  final AuthRepository repository;

  SendEmailVerificationOTPUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, {String? name}) {
    return repository.sendEmailVerificationOTP(email, name: name);
  }
}
