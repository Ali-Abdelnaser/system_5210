import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final double? width;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isAr = languageCode == 'ar';
    final name = recipe.getName(languageCode);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          opacity: 0.1,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Badge
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
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 140,
                            color: Colors.grey[100],
                            child: const Center(
                              child: AppLoadingIndicator(size: 24),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
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
                            size: 40,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.appBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 10,
                            color: AppTheme.appBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${recipe.ingredientsAr.length} ${isAr ? 'مكونات' : 'Ingredients'}',
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
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
      ),
    );
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
