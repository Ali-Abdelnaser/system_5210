import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOTPUseCase {
  final AuthRepository repository;

  VerifyEmailOTPUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) {
    return repository.verifyEmailOTP(email, code);
  }
}
