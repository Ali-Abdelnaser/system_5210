import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/games/bonding_game/data/models/bonding_challenge.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/features/games/bonding_game/presentation/widgets/custom_scratcher.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_game_selection_view.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_wall_view.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class BondingDailyCard extends StatelessWidget {
  const BondingDailyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BondingGameCubit, BondingGameState>(
      builder: (context, state) {
        if (kDebugMode) {
          print("BondingDailyCard State: $state");
        }
        if (state is BondingGameInitial || state is BondingGameLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BondingGameReady) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            height: 220,
            child: _buildScratchContent(context, state),
          );
        }

        if (state is BondingGameError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.message,
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  onPressed: () => context.read<BondingGameCubit>().initGame(),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildScratchContent(BuildContext context, BondingGameReady state) {
    if (state.selectedChallenge != null) {
      return _buildUnderneathContent(context, state);
    }
    return CustomScratcher(
      brushSize: 35,
      coverImagePath: AppImages.card,
      onScratchStart: () {
        context.read<BondingGameCubit>().setScrollingLocked(true);
      },
      onScratchEnd: () {
        context.read<BondingGameCubit>().setScrollingLocked(false);
      },
      child: _buildUnderneathContent(context, state),
    );
  }

  Widget _buildUnderneathContent(BuildContext context, BondingGameReady state) {
    final l10n = AppLocalizations.of(context)!;
    final isParent = state.currentTurn == BondingRole.parent;
    final roleName = isParent ? l10n.roleParent : l10n.roleChild;
    final primaryColor = isParent ? AppTheme.appBlue : AppTheme.appGreen;
    final hasSelected = state.selectedChallenge != null;
    final isDone = state.isMissionAccomplished;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isDone ? AppTheme.appGreen : primaryColor).withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDone ? AppTheme.appGreen : primaryColor).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative Glow Orbs (Subtle)
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withOpacity(0.08),
                      primaryColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isDone ? AppTheme.appGreen : primaryColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone
                              ? Icons.stars_rounded
                              : (hasSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.auto_awesome_rounded),
                          size: 14,
                          color: isDone ? AppTheme.appGreen : primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDone
                              ? l10n.bondingMissionAccomplished
                              : (hasSelected
                                    ? l10n.bondingActiveChallenge
                                    : l10n.bondingDiscoveryToday),
                          style:
                              (Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? GoogleFonts.cairo
                              : GoogleFonts.poppins)(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? AppTheme.appGreen
                                    : primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  if (isDone) ...[
                    // Done State
                    const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.appRed,
                          size: 40,
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 1.seconds),
                    const SizedBox(height: 8),
                    Text(
                      l10n.bondingMemoriesDay,
                      textAlign: TextAlign.center,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D3142),
                          ),
                    ),
                    Text(
                      l10n.bondingExploreMemories,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ] else if (hasSelected) ...[
                    // Selection Icon (Subtle)
                    Icon(
                      isParent
                          ? Icons.family_restroom_rounded
                          : Icons.child_care_rounded,
                      color: primaryColor.withOpacity(0.2),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    // Active Challenge Title
                    Text(
                      state.selectedChallenge!.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D3142),
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.bondingMissionFor(roleName),
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ] else ...[
                    // Selection Turn Intro
                    Text(
                      roleName,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D3142),
                          ),
                    ),
                    Text(
                      l10n.bondingTurnToChoose,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],

                  const Spacer(),

                  // Action Button
                  _buildPremiumButton(
                    context,
                    isDone ? AppTheme.appBlue : primaryColor,
                    isDone,
                  ),

                  if (!hasSelected && !isDone) ...[
                    const SizedBox(height: 8),
                    _AnimatedDownArrow(color: Colors.grey.withOpacity(0.3)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, Color color, bool isDone) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<BondingGameCubit>().state as BondingGameReady;
    final hasSelected = state.selectedChallenge != null;

    return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isDone) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<BondingGameCubit>(),
                        child: const BondingWallView(),
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<BondingGameCubit>(),
                        child: const BondingGameSelectionView(),
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDone
                          ? Icons.photo_library_rounded
                          : (hasSelected
                                ? Icons.camera_enhance_rounded
                                : Icons.flash_on_rounded),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isDone
                          ? l10n.bondingViewMemories
                          : (hasSelected
                                ? l10n.bondingDocumentMoment
                                : l10n.bondingDiscoverChallenge),
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1));
  }
}

class _AnimatedDownArrow extends StatelessWidget {
  final Color color;
  const _AnimatedDownArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Text(
              AppLocalizations.of(context)!.bondingScratchToDiscover,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 16),
          ],
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: 5,
          duration: 1.5.seconds,
          curve: Curves.easeInOut,
        );
  }
}
