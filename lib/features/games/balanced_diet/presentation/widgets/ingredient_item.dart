import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/games/balanced_diet/domain/entities/ingredient_entity.dart';

class IngredientItem extends StatelessWidget {
  final IngredientEntity ingredient;
  final bool isSelected;
  final VoidCallback onTap;

  const IngredientItem({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<IngredientEntity>(
      data: ingredient,
      maxSimultaneousDrags: isSelected
          ? 0
          : 1, // Prevent dragging if already selected
      feedback: Material(
        color: Colors.transparent,
        child:
            Image.asset(
              ingredient.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ).animate().scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
            ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildMainContent()),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onTap: isSelected ? onTap : null, // Allow deselect via tap
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppTheme.appGreen
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.appGreen.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(ingredient.imagePath, fit: BoxFit.contain)
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                ),

            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.appGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ).animate().scale(),
          ],
        ),
      ),
    );
  }
}
