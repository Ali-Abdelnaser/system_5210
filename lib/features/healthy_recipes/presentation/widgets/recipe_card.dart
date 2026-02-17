import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final name = recipe.getName(languageCode);

    return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Hero
                Stack(
                  children: [
                    Hero(
                      tag: 'recipe_${recipe.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Image.network(
                          recipe.imageUrl,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 140,
                              color: Colors.grey[200],
                              child: const AppLoadingIndicator(size: 30),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade200,
                                      Colors.pink.shade200,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                    ),
                    PositionBagde(languageCode: languageCode),
                  ],
                ),
                // Details Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (languageCode == 'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts.poppins)(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3142),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 14,
                            color: AppTheme.appBlue.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.ingredientsAr.length} ${languageCode == 'ar' ? 'مكونات' : 'Ingredients'}',
                            style:
                                (languageCode == 'ar'
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}

class PositionBagde extends StatelessWidget {
  const PositionBagde({super.key, required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final isAr = languageCode == 'ar';
    return Positioned(
      top: 12,
      right: isAr ? null : 12,
      left: isAr ? 12 : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Healthy',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
