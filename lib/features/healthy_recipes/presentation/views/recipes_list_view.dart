import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import '../manager/recipe_cubit.dart';
import '../manager/recipe_state.dart';
import '../widgets/recipe_card.dart';
import 'package:system_5210/features/specialists/presentation/views/admin_login_view.dart';

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
    final isAr = languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          RefreshIndicator(
            onRefresh: () => context.read<RecipeCubit>().getRecipes(),
            color: AppTheme.appBlue,
            backgroundColor: Colors.white,
            edgeOffset: 140, // Adjust to start below the app bar if needed
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 140.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: const AppBackButton(),
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                      onTap: () {
                        _tapCount++;
                        if (_tapCount == 4) {
                          _tapCount = 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLoginView(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      l10n.healthyRecipes,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),

                // Search Bar Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _buildSearchField(l10n, languageCode),
                  ),
                ),

                // Content Grid
                BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    if (state is RecipeLoading) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => AppShimmer.recipeGridCard(),
                            childCount: 6,
                          ),
                        ),
                      );
                    } else if (state is RecipeLoaded) {
                      final recipes = _isSearching
                          ? _filteredRecipes
                          : state.recipes;

                      if (recipes.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noRecipes,
                                  style:
                                      (isAr
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.72,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return RecipeCard(
                                  recipe: recipes[index],
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.recipeDetails,
                                    arguments: recipes[index],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .scale(
                                  begin: const Offset(0.95, 0.95),
                                  curve: Curves.easeOutBack,
                                );
                          }, childCount: recipes.length),
                        ),
                      );
                    } else if (state is RecipeError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: AppTheme.appRed),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, String languageCode) {
    final isAr = languageCode == 'ar';
    return GlassContainer(
      blur: 20,
      opacity: 0.8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
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
          hintStyle: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.appBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }
}
