import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/features/specialists/domain/repositories/specialists_repository.dart';

class GetSpecialists {
  final SpecialistsRepository repository;

  GetSpecialists(this.repository);

  Future<Either<Failure, List<Doctor>>> call() async {
    return await repository.getSpecialists();
  }
}
