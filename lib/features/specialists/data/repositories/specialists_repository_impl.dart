import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/specialists/data/datasources/specialists_remote_data_source.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/features/specialists/domain/repositories/specialists_repository.dart';

class SpecialistsRepositoryImpl implements SpecialistsRepository {
  final SpecialistsRemoteDataSource remoteDataSource;

  SpecialistsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Doctor>>> getSpecialists() async {
    try {
      final specialists = await remoteDataSource.getSpecialists();
      return Right(specialists);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Doctor>>> searchSpecialists(String query) async {
    try {
      final specialists = await remoteDataSource.getSpecialists();
      final filtered = specialists
          .where(
            (d) =>
                d.nameEn.toLowerCase().contains(query.toLowerCase()) ||
                d.nameAr.toLowerCase().contains(query.toLowerCase()) ||
                d.specialtyEn.toLowerCase().contains(query.toLowerCase()) ||
                d.specialtyAr.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
