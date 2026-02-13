import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_recipes_usecase.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final GetRecipesUseCase getRecipesUseCase;

  RecipeCubit({required this.getRecipesUseCase}) : super(RecipeInitial());

  Future<void> getRecipes() async {
    emit(RecipeLoading());
    final result = await getRecipesUseCase();
    result.fold(
      (failure) => emit(RecipeError(failure.message)),
      (recipes) => emit(RecipeLoaded(recipes)),
    );
  }
}
