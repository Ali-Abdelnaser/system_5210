import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPasswordResetOTPUseCase {
  final AuthRepository repository;

  VerifyPasswordResetOTPUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) async {
    return await repository.verifyPasswordResetOTP(email, code);
  }
}
