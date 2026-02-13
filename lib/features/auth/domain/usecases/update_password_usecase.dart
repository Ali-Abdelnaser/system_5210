import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_5210/core/usecases/usecase.dart';

class UpdatePasswordUseCase extends UseCase<void, UpdatePasswordParams> {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    return await repository.updatePassword(
      params.currentPassword,
      params.newPassword,
    );
  }
}

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
