import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class CheckEmailExistsUseCase {
  final AuthRepository repository;

  CheckEmailExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmailExists(email);
  }
}
