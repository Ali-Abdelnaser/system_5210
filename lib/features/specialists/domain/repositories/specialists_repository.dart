import 'package:dartz/dartz.dart';
import 'package:five2ten/core/errors/failures.dart';
import 'package:five2ten/features/specialists/domain/entities/doctor.dart';

abstract class SpecialistsRepository {
  Future<Either<Failure, List<Doctor>>> getSpecialists();
  Future<Either<Failure, List<Doctor>>> searchSpecialists(String query);
}
