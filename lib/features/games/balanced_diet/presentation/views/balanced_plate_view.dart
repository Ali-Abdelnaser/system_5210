import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import '../cubit/balanced_plate_cubit.dart';
import '../cubit/balanced_plate_state.dart';
import '../widgets/game_progress_bar.dart';
import '../widgets/ingredients_panel.dart';
import '../widgets/submit_plate_button.dart';
import '../widgets/game_feedback_overlay.dart';
import '../widgets/plate_widget.dart';
import '../widgets/game_result_overlay.dart';
import '../../domain/entities/ingredient_entity.dart';

class BalancedPlateView extends StatelessWidget {
  const BalancedPlateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BalancedPlateCubit>()..startGame(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const AppBackButton(),
              title: Text(
                'لعبة الطبق المتوازن',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3142),
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
              actions: [
                IconButton(
                  onPressed: () => _showInstructions(context),
                  icon: const Icon(Icons.help_outline),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    AppImages.authBackground,
                    fit: BoxFit.cover,
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // Progress Bar
                      BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                        builder: (context, state) {
                          int count = 0;
                          if (state is BalancedPlateGameInProgress) {
                            count = state.selectedIngredients.length;
                          }
                          return GameProgressBar(currentCount: count);
                        },
                      ),

                      const SizedBox(height: 5),

                      // Plate Display (DragTarget)
                      Expanded(
                        child:
                            BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                              builder: (context, state) {
                                List<IngredientEntity> selected = [];
                                if (state is BalancedPlateGameInProgress) {
                                  selected = state.selectedIngredients;
                                } else if (state is BalancedPlateSuccess) {
                                  selected = state.selectedIngredients;
                                }

                                return PlateWidget(
                                  selectedIngredients: selected,
                                  onIngredientDropped: (ingredient) {
                                    context
                                        .read<BalancedPlateCubit>()
                                        .addIngredient(ingredient);
                                  },
                                  onIngredientRemoved: (ingredient) {
                                    context
                                        .read<BalancedPlateCubit>()
                                        .removeIngredient(ingredient);
                                  },
                                );
                              },
                            ),
                      ),

                      // Ingredients Panel
                      BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                        builder: (context, state) {
                          if (state is BalancedPlateGameInProgress) {
                            return IngredientsPanel(
                              allIngredients: state.allIngredients,
                              selectedIngredients: state.selectedIngredients,
                              onIngredientRemoved: (ingredient) {
                                context
                                    .read<BalancedPlateCubit>()
                                    .removeIngredient(ingredient);
                              },
                            );
                          }
                          return const SizedBox(height: 180);
                        },
                      ),

                      // Action Button
                      BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                        builder: (context, state) {
                          bool canSubmit = false;
                          if (state is BalancedPlateGameInProgress) {
                            canSubmit = state.selectedIngredients.length == 5;
                          }

                          return SubmitPlateButton(
                            isEnabled: canSubmit,
                            onPressed: () => context
                                .read<BalancedPlateCubit>()
                                .submitPlate(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Floating Feedback Overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 130,
                  left: 20,
                  right: 20,
                  child: BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                    builder: (context, state) {
                      if (state is BalancedPlateGameInProgress &&
                          state.feedbackMessage != null) {
                        return GameFeedbackOverlay(
                          message: state.feedbackMessage!,
                          isHealthy: state.lastAddedIsHealthy ?? true,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Overlays
                BlocBuilder<BalancedPlateCubit, BalancedPlateState>(
                  builder: (context, state) {
                    if (state is BalancedPlateSuccess) {
                      return GameResultOverlay(
                        isBalanced: state.isBalanced,
                        stars: state.stars,
                        characterImagePath: state.characterImagePath,
                        onRetry: () =>
                            context.read<BalancedPlateCubit>().startGame(),
                        onExit: () => Navigator.pop(context),
                      );
                    } else if (state is BalancedPlateLoading) {
                      return Container(
                        color: Colors.black26,
                        child: Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(20),
                              child: const AppLoadingIndicator(),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    AppAlerts.showCustomDialog(
      context,
      title: '🎮 إزاي نلعب؟',
      message:
          'اسحب الأكل اللي بتحبه وحطه في الطبق وعشان تشيل أي أكلة، اسحبها من الطبق ورجعها مكانها تحت \n\nعشان تكون بطل، طبقك محتاج يكون فيه أكل صحي أكتر من 3 أنواع. وبالتوفيق يا بطل ✨',
      buttonText: 'فهمت',
      onPressed: () => Navigator.pop(context),
      isSuccess: true,
      icon: Icons.lightbulb_outline_rounded,
    );
  }
}
