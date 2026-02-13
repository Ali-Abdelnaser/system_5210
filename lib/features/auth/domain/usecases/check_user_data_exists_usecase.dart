import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class CheckUserDataExistsUseCase {
  final AuthRepository repository;

  CheckUserDataExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String uid) {
    return repository.checkUserDataExists(uid);
  }
}
