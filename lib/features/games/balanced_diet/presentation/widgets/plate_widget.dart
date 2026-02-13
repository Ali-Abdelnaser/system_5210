import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/games/balanced_diet/domain/entities/ingredient_entity.dart';

class PlateWidget extends StatelessWidget {
  final List<IngredientEntity> selectedIngredients;
  final Function(IngredientEntity) onIngredientDropped;
  final Function(IngredientEntity) onIngredientRemoved;

  const PlateWidget({
    super.key,
    required this.selectedIngredients,
    required this.onIngredientDropped,
    required this.onIngredientRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<IngredientEntity>(
      onWillAcceptWithDetails: (details) =>
          selectedIngredients.length < 5 &&
          !selectedIngredients.contains(details.data),
      onAcceptWithDetails: (details) => onIngredientDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Center(
          child: AnimatedScale(
            scale: isHovering ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing effect when dragging over
                if (isHovering)
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                // The Plate Image
                Image.asset(
                  AppImages.plate,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),

                // Positioned Ingredients on the plate
                ...List.generate(selectedIngredients.length, (index) {
                  final ingredient = selectedIngredients[index];
                  return _PlateIngredientDraggable(
                    key: ValueKey(
                      ingredient.id,
                    ), // KEY IS CRITICAL TO PREVENT SHAKE
                    index: index,
                    ingredient: ingredient,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlateIngredientDraggable extends StatelessWidget {
  final int index;
  final IngredientEntity ingredient;

  const _PlateIngredientDraggable({
    super.key,
    required this.index,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    // Balanced pentagonal arrangement on the plate
    final positions = [
      const Offset(0, -60), // Top
      const Offset(-65, -10), // Left
      const Offset(65, -10), // Right
      const Offset(-35, 50), // Bottom Left
      const Offset(35, 50), // Bottom Right
    ];

    // Subtle random-looking rotations for natural feel
    final rotations = [
      0.1, // Slightly tilted
      -0.15,
      0.08,
      -0.05,
      0.12,
    ];

    if (index >= positions.length) return const SizedBox();
    final pos = positions[index];
    final rotation = rotations[index];

    return Transform.translate(
      offset: pos,
      child: Transform.rotate(
        angle: rotation,
        child: Draggable<IngredientEntity>(
          data: ingredient,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                ingredient.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          childWhenDragging: const SizedBox(),
          child:
              Image.asset(
                    ingredient.imagePath,
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                    duration: 400.ms,
                  )
                  .shimmer(delay: 500.ms, duration: 1.seconds),
        ),
      ),
    );
  }
}
