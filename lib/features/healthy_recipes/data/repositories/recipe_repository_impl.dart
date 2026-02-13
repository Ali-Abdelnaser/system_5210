import 'package:dartz/dartz.dart';
import 'package:system_5210/core/errors/failures.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Recipe>>> getRecipes() async {
    try {
      final recipes = await remoteDataSource.getRecipes();
      return Right(recipes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
