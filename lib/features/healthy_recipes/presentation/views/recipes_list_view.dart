import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../manager/recipe_cubit.dart';
import '../manager/recipe_state.dart';
import '../widgets/recipe_card.dart';

class RecipesListView extends StatefulWidget {
  const RecipesListView({super.key});

  @override
  State<RecipesListView> createState() => _RecipesListViewState();
}

class _RecipesListViewState extends State<RecipesListView> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  bool _isSearching = false;
  int _tapCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecipes(
    List<Recipe> allRecipes,
    String query,
    String languageCode,
  ) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = allRecipes;
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredRecipes = allRecipes.where((recipe) {
          final name = recipe.getName(languageCode).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: GestureDetector(
          onTap: () {
            _tapCount++;
            if (_tapCount == 4) {
              _tapCount = 0;
              Navigator.pushNamed(context, AppRoutes.uploader);
            }
          },
          child: Text(
            l10n.healthyRecipes,
            style:
                (languageCode == 'ar'
                ? GoogleFonts.cairo
                : GoogleFonts.poppins)(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3142),
                ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchField(l10n, languageCode),
          Expanded(
            child: BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                if (state is RecipeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RecipeLoaded) {
                  final recipes = _isSearching
                      ? _filteredRecipes
                      : state.recipes;

                  if (recipes.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noRecipes,
                        style: (languageCode == 'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts
                                  .poppins)(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(
                        recipe: recipes[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetails,
                          arguments: recipes[index],
                        ),
                      );
                    },
                  );
                } else if (state is RecipeError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, String languageCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            final state = context.read<RecipeCubit>().state;
            if (state is RecipeLoaded) {
              _filterRecipes(state.recipes, value, languageCode);
            }
          },
          decoration: InputDecoration(
            hintText: l10n.searchRecipes,
            hintStyle: (languageCode == 'ar'
                ? GoogleFonts.cairo
                : GoogleFonts.poppins)(fontSize: 14, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, color: AppTheme.appBlue),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}
