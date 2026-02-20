import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class BondingGameContractView extends StatefulWidget {
  const BondingGameContractView({super.key});

  @override
  State<BondingGameContractView> createState() =>
      _BondingGameContractViewState();
}

class _BondingGameContractViewState extends State<BondingGameContractView>
    with TickerProviderStateMixin {
  double _syncProgress = 0.0;
  bool _isParentTouching = false;
  bool _isChildTouching = false;
  bool _isFinalized = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (_isFinalized) return;

    if (_isParentTouching && _isChildTouching) {
      setState(() {
        _syncProgress += 0.02; // Fill speed
        if (_syncProgress >= 1.0) {
          _syncProgress = 1.0;
          _isFinalized = true;
          _onContractSealed();
        }
      });
      // Continue filling if still touching
      Future.delayed(const Duration(milliseconds: 30), _updateProgress);
    } else {
      // Slowly drain if not both touching
      if (_syncProgress > 0 && !_isFinalized) {
        setState(() {
          _syncProgress -= 0.01;
          if (_syncProgress < 0) _syncProgress = 0;
        });
        Future.delayed(const Duration(milliseconds: 30), _updateProgress);
      }
    }
  }

  void _onContractSealed() {
    final l10n = AppLocalizations.of(context)!;
    AppAlerts.showCustomDialog(
      context,
      title: l10n.bondingConfirmChallenge,
      message: l10n.bondingCommitmentSuccess,
      buttonText: l10n.bondingStartNow,
      isSuccess: true,
      icon: Icons.check_circle_rounded,
      onPressed: () {
        context.read<BondingGameCubit>().signContract();
        context.read<BondingGameCubit>().completeChallenge();
        // Pop the dialog
        Navigator.of(context).pop();
        // Pop the Contract view to go back to Selection view (which now shows active mission)
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Core Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // 2. The Energy Portal (Content)
          SafeArea(
            child: BlocBuilder<BondingGameCubit, BondingGameState>(
              builder: (context, state) {
                if (state is BondingGameReady) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          // Top Section: Parent Power Source
                          Expanded(
                            flex: 3,
                            child: _buildRoleSection(
                              label: l10n.roleParent,
                              pledge: l10n.bondingPledgeParent,
                              color: AppTheme.appBlue,
                              icon: Icons.fingerprint_rounded,
                              isTouching: _isParentTouching,
                              isTop: true,
                              onTouch: (val) {
                                setState(() => _isParentTouching = val);
                                _updateProgress();
                              },
                            ),
                          ),

                          // Middle Section: Objective Orb (Gap for floating hub)
                          const SizedBox(height: 140),

                          // Bottom Section: Child Power Source
                          Expanded(
                            flex: 3,
                            child: _buildRoleSection(
                              label: l10n.roleChild,
                              pledge: l10n.bondingPledgeChild,
                              color: AppTheme.appGreen,
                              icon: Icons.fingerprint_rounded,
                              isTouching: _isChildTouching,
                              isTop: false,
                              onTouch: (val) {
                                setState(() => _isChildTouching = val);
                                _updateProgress();
                              },
                            ),
                          ),
                        ],
                      ),

                      // 3. The Central Mission Hub (Floating)
                      Center(child: _buildCentralOrb(state)),

                      // 4. Progress Indicators (Beams)
                      _buildEnergyBeams(),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection({
    required String label,
    required String pledge,
    required Color color,
    required IconData icon,
    required bool isTouching,
    required bool isTop,
    required Function(bool) onTouch,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      mainAxisAlignment: isTop
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        if (isTop) ...[
          Text(
            l10n.bondingConfirmChallenge,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.appBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bondingFingerprintInstruction,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              color: AppTheme.appBlue.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: GestureDetector(
            onTapDown: (_) => onTouch(true),
            onTapUp: (_) => onTouch(false),
            onTapCancel: () => onTouch(false),
            child:
                GlassContainer(
                      borderRadius: BorderRadius.circular(35),
                      blur: 25,
                      opacity: isTouching ? 0.25 : 0.1,
                      color: color,
                      border: Border.all(
                        color: isTouching ? color : color.withOpacity(0.3),
                        width: 3,
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // Fingerprint Scanner Area
                              Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isTouching
                                              ? color
                                              : Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          border: Border.all(
                                            color: isTouching
                                                ? Colors.white
                                                : color.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.fingerprint_rounded,
                                          color: isTouching
                                              ? Colors.white
                                              : color,
                                          size: 44,
                                        ),
                                      ),
                                      if (isTouching)
                                        // Scanning Bar Animation
                                        Positioned(
                                          top: 0,
                                          child:
                                              Container(
                                                    width: 55,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .animate(
                                                    onPlay: (c) => c.repeat(),
                                                  )
                                                  .moveY(
                                                    begin: 10,
                                                    end: 55,
                                                    duration: 1200.ms,
                                                  ),
                                        ),
                                    ],
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .shimmer(
                                    duration: 2000.ms,
                                    color: color.withOpacity(0.1),
                                  ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style:
                                          (isAr
                                          ? GoogleFonts.cairo
                                          : GoogleFonts.poppins)(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: isTouching
                                                ? Colors.white
                                                : color,
                                          ),
                                    ),
                                    Text(
                                      pledge,
                                      style:
                                          (isAr
                                          ? GoogleFonts.cairo
                                          : GoogleFonts.poppins)(
                                            fontSize: 14,
                                            color: isTouching
                                                ? Colors.white.withOpacity(0.9)
                                                : const Color(0xFF374151),
                                            height: 1.3,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            isTouching
                                ? l10n.bondingConfirming
                                : l10n.bondingConfirmFromHere,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isTouching
                                      ? Colors.white
                                      : color.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    )
                    .animate(target: isTouching ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.98, 0.98),
                    )
                    .boxShadow(
                      begin: const BoxShadow(color: Colors.transparent),
                      end: BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 30,
                      ),
                    ),
          ),
        ),

        if (!isTop) const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCentralOrb(BondingGameReady state) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    bool isBothTouching = _isParentTouching && _isChildTouching;

    return Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: (isBothTouching ? AppTheme.appYellow : Colors.white)
                    .withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(100),
            blur: 20,
            opacity: 0.15,
            color: AppTheme.appYellow,
            border: Border.all(
              color: isBothTouching
                  ? AppTheme.appYellow
                  : Colors.white.withOpacity(0.5),
              width: 4,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: isBothTouching
                        ? AppTheme.appYellow
                        : AppTheme.appBlue.withOpacity(0.2),
                    size: 35,
                  ).animate(target: isBothTouching ? 1 : 0).scale().rotate(),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      l10n.bondingGameTitle,
                      textAlign: TextAlign.center,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appBlue.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      state.selectedChallenge?.title ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.appBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 2000.ms,
        );
  }

  Widget _buildEnergyBeams() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Beam (Parent)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              child: AnimatedOpacity(
                opacity: _isParentTouching ? 1.0 : 0.0,
                duration: 300.ms,
                child: Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.appBlue,
                        AppTheme.appYellow.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Beam (Child)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.35,
              child: AnimatedOpacity(
                opacity: _isChildTouching ? 1.0 : 0.0,
                duration: 300.ms,
                child: Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.appGreen,
                        AppTheme.appYellow.withOpacity(0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Central Progress Ring around the Orb
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: _syncProgress,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _syncProgress > 0.8 ? AppTheme.appYellow : AppTheme.appRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
