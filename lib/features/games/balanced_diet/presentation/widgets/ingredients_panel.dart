import 'package:flutter/material.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import '../../domain/entities/ingredient_entity.dart';
import 'ingredient_item.dart';

class IngredientsPanel extends StatelessWidget {
  final List<IngredientEntity> allIngredients;
  final List<IngredientEntity> selectedIngredients;
  final Function(IngredientEntity) onIngredientRemoved;

  const IngredientsPanel({
    super.key,
    required this.allIngredients,
    required this.selectedIngredients,
    required this.onIngredientRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DragTarget<IngredientEntity>(
        onWillAcceptWithDetails: (details) {
          return selectedIngredients.contains(details.data);
        },
        onAcceptWithDetails: (details) {
          onIngredientRemoved(details.data);
        },
        builder: (context, candidateData, rejectedData) => GlassContainer(
          blur: 9,
          opacity: candidateData.isNotEmpty ? 0.3 : 0.1,
          color: candidateData.isNotEmpty ? Colors.red.withOpacity(0.2) : null,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
            bottom: Radius.circular(30),
          ),
          child: SizedBox(
            height: 180, // Fixed height for 2 rows of items
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = allIngredients[index];
                final isSelected = selectedIngredients.contains(ingredient);
                return IngredientItem(
                  ingredient: ingredient,
                  isSelected: isSelected,
                  onTap: () => onIngredientRemoved(ingredient),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
