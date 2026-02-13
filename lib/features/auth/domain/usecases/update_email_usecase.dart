import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/core/usecases/usecase.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';

class UpdateEmailUseCase extends UseCase<void, UpdateEmailParams> {
  final AuthRepository repository;

  UpdateEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmailParams params) async {
    return await repository.updateEmail(
      params.currentPassword,
      params.newEmail,
    );
  }
}

class UpdateEmailParams {
  final String currentPassword;
  final String newEmail;

  UpdateEmailParams({required this.currentPassword, required this.newEmail});
}
