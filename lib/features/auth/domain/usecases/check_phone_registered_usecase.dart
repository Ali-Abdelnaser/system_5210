import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class CheckPhoneRegisteredUseCase {
  final AuthRepository repository;

  CheckPhoneRegisteredUseCase(this.repository);

  Future<Either<Failure, bool>> call(String phoneNumber) async {
    return await repository.checkPhoneNumberExists(phoneNumber);
  }
}
