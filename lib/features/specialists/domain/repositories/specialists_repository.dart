import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';

abstract class SpecialistsRepository {
  Future<Either<Failure, List<Doctor>>> getSpecialists();
  Future<Either<Failure, List<Doctor>>> searchSpecialists(String query);
}
