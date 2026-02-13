import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../manager/recipe_cubit.dart';
import '../manager/recipe_state.dart';
import '../widgets/recipe_card.dart';

class RecipesSection extends StatelessWidget {
  const RecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        _buildSectionTitle(
          context: context,
          title: l10n.healthyRecipes,
          actionText: l10n.seeAll,
          onActionTap: () =>
              Navigator.pushNamed(context, AppRoutes.healthyRecipes),
          languageCode: languageCode,
        ),
        SizedBox(
          height: 240,
          child: BlocBuilder<RecipeCubit, RecipeState>(
            builder: (context, state) {
              if (state is RecipeLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => AppShimmer.recipeCard(),
                );
              } else if (state is RecipeLoaded) {
                final recipes = state.recipes.take(5).toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == recipes.length) {
                      return _buildSeeAllCard(context, l10n, languageCode);
                    }
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
    );
  }

  Widget _buildSectionTitle({
    required BuildContext context,
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
    required String languageCode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                (languageCode == 'ar'
                ? GoogleFonts.cairo
                : GoogleFonts.poppins)(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3142),
                ),
          ),
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionText,
              style:
                  (languageCode == 'ar'
                  ? GoogleFonts.cairo
                  : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.appBlue,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllCard(
    BuildContext context,
    AppLocalizations l10n,
    String languageCode,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.healthyRecipes),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.appBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.appBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.seeAll,
              style:
                  (languageCode == 'ar'
                  ? GoogleFonts.cairo
                  : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.appBlue,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
