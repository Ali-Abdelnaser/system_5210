import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_game_selection_view.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_wall_view.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class BondingGameDashboardView extends StatelessWidget {
  const BondingGameDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Decor
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
          ),
          BlocBuilder<BondingGameCubit, BondingGameState>(
            builder: (context, state) {
              if (state is BondingGameReady) {
                return SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(context, l10n, state),
                        const SizedBox(height: 30),
                        _buildMissionHero(context, state, l10n),
                        const SizedBox(height: 35),
                        _buildSectionHeader(context, l10n.bondingWallTitle),
                        const SizedBox(height: 15),
                        _buildWallPreview(context, state),
                        const SizedBox(height: 40),
                        _buildValueProposition(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    AppLocalizations l10n,
    BondingGameReady state,
  ) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr
                  ? "صباح الصحة والسعادة ✨"
                  : "Morning of Health & Happiness ✨",
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.appBlue.withOpacity(0.5),
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 4),
            Text(
              l10n.bondingGameTitle,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.appBlue,
                height: 1.1,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          ],
        ),
        if (state.streakCount > 0)
          Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Colors.orange,
                        Color(0xFFFF9800),
                        Color(0xFFFFB74D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse Effect
                      Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.5, 1.5),
                            duration: 2.seconds,
                            curve: Curves.easeOut,
                          )
                          .fadeOut(),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          Text(
                            "${state.streakCount}",
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                          ),
                          Text(
                            isAr ? "يوم" : "Days",
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 0.8,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: const Offset(0, 0),
                end: const Offset(0, -8),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
      ],
    );
  }

  Widget _buildMissionHero(
    BuildContext context,
    BondingGameReady state,
    AppLocalizations l10n,
  ) {
    final bool isSigned = state.isContractSigned;
    final bool isDone = state.isMissionAccomplished;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Determine visuals based on state
    Color topColor;
    Color bottomColor;
    String statusTitle;
    String actionText;
    String badgeText;
    IconData heroIcon;

    if (isDone) {
      topColor = const Color(0xFF10B981); // Emerald
      bottomColor = const Color(0xFF059669);
      statusTitle = l10n.bondingMissionAccomplished;
      actionText = l10n.bondingViewMemories;
      badgeText = l10n.bondingDoneBadge;
      heroIcon = Icons.stars_rounded;
    } else if (isSigned) {
      topColor = const Color(0xFF34D399); // Medium Green
      bottomColor = const Color(0xFF10B981);
      statusTitle = l10n.bondingActiveChallenge;
      actionText = l10n.bondingDocumentMoment;
      badgeText = l10n.bondingActiveBadge;
      heroIcon = Icons.bolt_rounded;
    } else {
      topColor = const Color(0xFF3B82F6); // Blue
      bottomColor = const Color(0xFF2563EB);
      statusTitle = l10n.bondingDiscoveryToday;
      actionText = l10n.bondingDiscoverChallenge;
      badgeText = l10n.bondingAvailableBadge;
      heroIcon = Icons.auto_awesome_rounded;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topColor, bottomColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: bottomColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Decorative Spheres
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSigned || isDone)
                              Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                  .animate(onPlay: (c) => c.repeat())
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.5, 1.5),
                                    duration: 1.seconds,
                                  )
                                  .fadeOut(),
                            if (isSigned || isDone) const SizedBox(width: 8),
                            Text(
                              badgeText,
                              style:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(heroIcon, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusTitle,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDone
                        ? l10n.bondingMemoriesDay
                        : (isSigned
                              ? l10n.bondingEnjoyChallenge
                              : l10n.bondingHomeAnnouncement),
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (isDone) {
                          _navigateToWall(context);
                        } else {
                          _navigateToGame(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 52,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            actionText,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: bottomColor,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.appBlue,
          ),
        ),
        TextButton(
          onPressed: () => _navigateToWall(context),
          child: Text(
            l10n.seeAll,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontWeight: FontWeight.bold,
              color: AppTheme.appBlue.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWallPreview(BuildContext context, BondingGameReady state) {
    final memories = state.wallMemories;
    if (memories.isEmpty) {
      return _buildEmptyWallPlaceholder(context);
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: memories.length > 5 ? 6 : memories.length,
        itemBuilder: (context, index) {
          if (index == 5) {
            return _buildViewAllCard(context);
          }
          final memory = memories[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(
                      File(memory.photoPaths.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        "${memory.date.split('-').last} / ${memory.date.split('-')[1]}",
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildEmptyWallPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return InkWell(
      onTap: () => _navigateToGame(context),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.all(30),
        blur: 10,
        opacity: 0.05,
        color: AppTheme.appBlue,
        border: Border.all(color: AppTheme.appBlue.withOpacity(0.1), width: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.appBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppTheme.appBlue,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bondingNoMemoriesYet,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.appBlue,
                    ),
                  ),
                  Text(
                    l10n.bondingStartFirstChallenge,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.appBlue.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return InkWell(
      onTap: () => _navigateToWall(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppTheme.appBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.appBlue.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.appBlue),
            const SizedBox(height: 8),
            Text(
              l10n.bondingViewAll,
              textAlign: TextAlign.center,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.appBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueProposition(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return GlassContainer(
      borderRadius: BorderRadius.circular(30),
      blur: 20,
      opacity: 0.1,
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Text(
                l10n.bondingWhyTitle,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.appBlue,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            l10n.bondingWhyDesc,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              color: AppTheme.appBlue.withOpacity(0.7),
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
            textAlign: isAr ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _navigateToGame(BuildContext context) {
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

  void _navigateToWall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BondingGameCubit>(),
          child: const BondingWallView(),
        ),
      ),
    );
  }
}
