import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class UpdateDisplayNameUseCase {
  final AuthRepository repository;

  UpdateDisplayNameUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) async {
    return await repository.updateDisplayName(name);
  }
}
