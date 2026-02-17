import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/games/quizGame/presentation/cubit/quiz_cubit.dart';
import 'package:system_5210/features/games/quizGame/presentation/cubit/quiz_state.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'quiz_game_view.dart';

class QuizLevelsView extends StatefulWidget {
  const QuizLevelsView({super.key});

  @override
  State<QuizLevelsView> createState() => _QuizLevelsViewState();
}

class _QuizLevelsViewState extends State<QuizLevelsView> {
  final int totalLevels = 14;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<QuizCubit>();
    cubit.loadLevels();

    // Handle case where state is already loaded (from a previous visit)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cubit.state is QuizLevelsLoaded) {
        _scrollToCurrentLevel(
          (cubit.state as QuizLevelsLoaded).lastUnlockedLevel,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLevel(int unlockedLevel) {
    // Add a small delay to ensure the list is fully rendered and layout is stable
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_scrollController.hasClients) return;

      // Approximate height per item based on UI structure
      const double itemHeight = 280.0;
      // Subtract half the screen height to center the level
      final double screenHeight = MediaQuery.of(context).size.height;
      final double scrollPosition =
          ((unlockedLevel - 2) * itemHeight) -
          (screenHeight / 2) +
          (itemHeight / 2);

      _scrollController.animateTo(
        scrollPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: 1200.ms,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // 2. Parallax Clouds Background
          _buildParallaxBackground(),

          BlocConsumer<QuizCubit, QuizState>(
            listener: (context, state) {
              if (state is QuizLevelsLoaded) {
                _scrollToCurrentLevel(state.lastUnlockedLevel);
              }
            },
            builder: (context, state) {
              int unlockedLevels = state.lastUnlockedLevel;
              Map<int, int> levelStars = state.levelStars;
              int totalStars = levelStars.values.fold(0, (sum, s) => sum + s);
              int totalScores = state.levelScores.values.fold(
                0,
                (sum, s) => sum + s,
              );

              return SafeArea(
                child: Column(
                  children: [
                    _buildHeader(totalStars, totalScores)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 0, bottom: 50),
                        child: CustomPaint(
                          painter: _QuizPathPainter(
                            levelCount: totalLevels,
                            unlockedLevels: unlockedLevels,
                          ),
                          child: Column(
                            children: List.generate(totalLevels, (index) {
                              final level = index + 1;
                              return _buildLevelIsland(
                                    level,
                                    unlockedLevels,
                                    levelStars[level] ?? 0,
                                    state.levelScores[level] ?? 0,
                                  )
                                  .animate()
                                  .fadeIn(
                                    duration: 800.ms,
                                    delay: (index * 100).ms,
                                  )
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1, 1),
                                    curve: Curves.easeOutBack,
                                  );
                            }),
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final double scrollOffset = _scrollController.hasClients
            ? _scrollController.offset
            : 0;

        return Stack(
          children: [
            // Layer 1: Far (Slowest, blurred)
            _buildParallaxCloud(
              top: 50,
              left: -40,
              scale: 0.5,
              opacity: 0.3,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 40,
              driftDistance: 60,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 350,
              left: 200,
              scale: 0.4,
              opacity: 0.25,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 50,
              driftDistance: -50,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 800,
              left: 50,
              scale: 0.6,
              opacity: 0.3,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 45,
              driftDistance: 80,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 1100,
              left: 250,
              scale: 0.45,
              opacity: 0.25,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 55,
              driftDistance: -70,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 1600,
              left: -80,
              scale: 0.55,
              opacity: 0.28,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 48,
              driftDistance: 90,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 2100,
              left: 150,
              scale: 0.5,
              opacity: 0.25,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 52,
              driftDistance: -80,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 2600,
              left: -30,
              scale: 0.6,
              opacity: 0.3,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 44,
              driftDistance: 100,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 3100,
              left: 200,
              scale: 0.45,
              opacity: 0.25,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 58,
              driftDistance: -60,
              blur: 3,
            ),
            _buildParallaxCloud(
              top: 3600,
              left: 40,
              scale: 0.55,
              opacity: 0.28,
              parallaxRate: 0.05,
              scrollOffset: scrollOffset,
              driftSpeed: 50,
              driftDistance: 110,
              blur: 3,
            ),

            // Layer 2: Mid (Medium speed)
            _buildParallaxCloud(
              top: 200,
              left: 250,
              scale: 0.8,
              opacity: 0.45,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 25,
              driftDistance: -100,
            ),
            _buildParallaxCloud(
              top: 600,
              left: -60,
              scale: 0.9,
              opacity: 0.4,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 30,
              driftDistance: 120,
            ),
            _buildParallaxCloud(
              top: 1200,
              left: 180,
              scale: 0.85,
              opacity: 0.4,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 28,
              driftDistance: -90,
            ),
            _buildParallaxCloud(
              top: 1800,
              left: 20,
              scale: 0.75,
              opacity: 0.45,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 32,
              driftDistance: 110,
            ),
            _buildParallaxCloud(
              top: 2400,
              left: 280,
              scale: 0.8,
              opacity: 0.4,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 27,
              driftDistance: -130,
            ),
            _buildParallaxCloud(
              top: 3000,
              left: -40,
              scale: 0.85,
              opacity: 0.45,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 34,
              driftDistance: 140,
            ),
            _buildParallaxCloud(
              top: 3400,
              left: 210,
              scale: 0.9,
              opacity: 0.4,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 29,
              driftDistance: -120,
            ),
            _buildParallaxCloud(
              top: 3800,
              left: 30,
              scale: 0.8,
              opacity: 0.45,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 31,
              driftDistance: 100,
            ),
            _buildParallaxCloud(
              top: 4200,
              left: 260,
              scale: 0.85,
              opacity: 0.4,
              parallaxRate: 0.2,
              scrollOffset: scrollOffset,
              driftSpeed: 33,
              driftDistance: -140,
            ),

            // Layer 3: Near (Fastest, clearest)
            _buildParallaxCloud(
              top: 450,
              left: 80,
              scale: 1.1,
              opacity: 0.65,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 20,
              driftDistance: 150,
            ),
            _buildParallaxCloud(
              top: 900,
              left: -20,
              scale: 1.3,
              opacity: 0.6,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 18,
              driftDistance: 100,
            ),
            _buildParallaxCloud(
              top: 1400,
              left: 100,
              scale: 1.2,
              opacity: 0.65,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 22,
              driftDistance: -130,
            ),
            _buildParallaxCloud(
              top: 2100,
              left: -50,
              scale: 1.4,
              opacity: 0.6,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 19,
              driftDistance: 140,
            ),
            _buildParallaxCloud(
              top: 2800,
              left: 200,
              scale: 1.15,
              opacity: 0.65,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 21,
              driftDistance: -110,
            ),
            _buildParallaxCloud(
              top: 3300,
              left: -20,
              scale: 1.25,
              opacity: 0.6,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 23,
              driftDistance: 150,
            ),
            _buildParallaxCloud(
              top: 3800,
              left: 150,
              scale: 1.35,
              opacity: 0.65,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 20,
              driftDistance: -120,
            ),
            _buildParallaxCloud(
              top: 4300,
              left: 50,
              scale: 1.2,
              opacity: 0.6,
              parallaxRate: 0.5,
              scrollOffset: scrollOffset,
              driftSpeed: 24,
              driftDistance: 130,
            ),
          ],
        );
      },
    );
  }

  Widget _buildParallaxCloud({
    required double top,
    required double left,
    required double scale,
    required double opacity,
    required double parallaxRate,
    required double scrollOffset,
    required int driftSpeed,
    required double driftDistance,
    double blur = 0.0,
  }) {
    // Parallax Logic: Move UP as we scroll DOWN (scrollOffset increases)
    // Applying a negative offset relative to scroll speed
    final double parallaxOffset = -scrollOffset * parallaxRate;

    return Positioned(
      top: top + parallaxOffset,
      left: left,
      child:
          ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(AppImages.cloud, width: 200 * scale),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(
                begin: 0,
                end: driftDistance,
                duration: driftSpeed.seconds,
                curve: Curves.easeInOutSine,
              )
              .moveY(
                begin: 0,
                end: 30, // Gentle bobbing separate from parallax
                duration: (driftSpeed * 0.8).seconds,
                curve: Curves.easeInOutSine,
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: (driftSpeed * 0.9).seconds,
                curve: Curves.easeInOutSine,
              ),
    );
  }

  Widget _buildHeader(int totalStars, int totalScores) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(),
              Text(
                'مغامرة المعرفة',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 48), // Balanced spacing
            ],
          ),
          const SizedBox(height: 15),
          // Stats Card
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total Points
                    _buildStatItem(
                      label: 'مجموع النقاط',
                      value: '$totalScores',
                      icon: Icons.stars_rounded,
                      iconColor: Colors.amber,
                    ),
                    const SizedBox(width: 30),
                    // Divider
                    Container(
                      height: 30,
                      width: 1.5,
                      color: const Color(0xFF1E293B).withOpacity(0.1),
                    ),
                    const SizedBox(width: 30),
                    // Total Stars
                    _buildStatItem(
                      label: 'النجوم الكلية',
                      value: '$totalStars',
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B).withOpacity(0.6),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelIsland(
    int level,
    int unlockedLevels,
    int stars,
    int score,
  ) {
    final bool isUnlocked = level <= unlockedLevels;
    final bool isCurrent = level == unlockedLevels;
    final bool shouldShowStars = level < unlockedLevels && stars > 0;

    return Padding(
      padding: EdgeInsets.only(
        top: 0,
        left: level % 2 != 0 ? 150 : 0,
        right: level % 2 == 0 ? 150 : 0,
        bottom: 50,
      ),
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            _showLevelInfoDialog(level, stars, score, isCurrent);
          } else {
            AppAlerts.showAlert(
              context,
              message:
                  'هذه الجزيرة مغلقة حالياً، أكمل التحديات السابقة لتصل إليها',
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 0. Glow effect for the current island
                if (isCurrent)
                  Container(
                        width: 220,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.6),
                              blurRadius: 70,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.1, 1.1),
                        duration: 2000.ms,
                        curve: Curves.easeInOut,
                      ),

                // 0. Shadow (Pulse effect)
                Positioned(
                  bottom: -20,
                  child:
                      Container(
                            width: 140,
                            height: 15,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                              borderRadius: const BorderRadius.all(
                                Radius.elliptical(140, 15),
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(0.6, 0.6),
                            duration: (1500 + (level % 4) * 500).ms,
                            curve: Curves.easeInOut,
                          )
                          .custom(
                            duration: (1500 + (level % 4) * 500).ms,
                            curve: Curves.easeInOut,
                            builder: (context, value, child) => Opacity(
                              opacity: 0.3 + (value * 0.7),
                              child: child,
                            ),
                          ),
                ),

                // Island and elements stack
                Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // 1. Island Image
                        Image.asset(
                          isUnlocked ? AppImages.island : AppImages.islandDark,
                          width: 180,
                        ),

                        // Lock Icon
                        if (!isUnlocked)
                          Positioned(
                            top: 5,
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  AppImages.iconLock,
                                  width: 40,
                                  colorFilter: const ColorFilter.mode(
                                    Color.fromARGB(179, 0, 0, 0),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  'Closed',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 2. Character
                        if (isCurrent)
                          Positioned(
                            top: -80,
                            child: Image.asset(
                              AppImages.gameSuccess1,
                              width: 140,
                            ),
                          ),

                        // 3. Points Badge (Above Stars)
                        if (shouldShowStars && score > 0)
                          Positioned(
                            top: -15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$score',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(),
                          ),

                        // 4. Stars
                        if (shouldShowStars)
                          Positioned(
                            top: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (i) {
                                final hasStar = i < stars;
                                return Icon(
                                  hasStar
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: hasStar
                                      ? Colors.amber
                                      : Colors.amber.withOpacity(0.5),
                                  size: 40,
                                );
                              }),
                            ),
                          ),

                        // 5. Level Label (Glassmorphism)
                        Positioned(
                          bottom: 65,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'Level $level',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .moveY(
                      begin: 0,
                      end: 10 + (level % 3) * 2,
                      duration: (1500 + (level % 4) * 500).ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .moveY(
                      begin: 10 + (level % 3) * 2,
                      end: 0,
                      duration: (1500 + (level % 4) * 500).ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelInfoDialog(int level, int stars, int score, bool isCurrent) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Premium Glass Card
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Level $level',
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Stars Row with animated glow
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => Icon(
                              index < stars
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 45,
                            ),
                          ).animate(interval: 100.ms).scale().shake(),
                        ),
                      ),
                      if (score > 0) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'أعلى نقطة: $score',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ).copyWith(
                                    overlayColor: MaterialStateProperty.all(
                                      Colors.white10,
                                    ),
                                  ),
                              onPressed: () {
                                final cubit = context.read<QuizCubit>();
                                Navigator.pop(dialogContext);
                                cubit.startLevel(level);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: cubit,
                                      child: QuizGameView(level: level),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                stars > 0 ? 'إعادة اللعب' : 'ابدأ الآن',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF1E293B),
                                  width: 2,
                                ),
                                foregroundColor: const Color(0xFF1E293B),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                'الخريطة',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Character Image Overlay
            Positioned(
              top: -90,
              child: Image.asset(AppImages.gameSuccess3, height: 200)
                  .animate()
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizPathPainter extends CustomPainter {
  final int levelCount;
  final int unlockedLevels;
  _QuizPathPainter({required this.levelCount, required this.unlockedLevels});

  @override
  void paint(Canvas canvas, Size size) {
    // Each level island roughly takes this height (island + padding)
    final double itemHeight = size.height / levelCount;

    for (int i = 0; i < levelCount - 1; i++) {
      final level = i + 1;
      final nextLevel = i + 2;

      // Color logic: Green if leading to/between unlocked levels, otherwise Gray
      final bool isPathUnlocked = nextLevel <= unlockedLevels;

      final paint = Paint()
        ..color = isPathUnlocked
            ? const Color(0xFF4CAF50).withOpacity(0.8)
            : const Color(0xFF94A3B8).withOpacity(0.4)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Logic based on LevelIsland padding:
      // Odd levels have left: 150 (pushed RIGHT)
      // Even levels have right: 150 (pushed LEFT)
      final startX = level % 2 != 0 ? size.width * 0.72 : size.width * 0.28;
      final endX = nextLevel % 2 != 0 ? size.width * 0.72 : size.width * 0.28;

      // Y positions are centers of each island item
      final startY = (i * itemHeight) + (itemHeight * 0.5);
      final endY = ((i + 1) * itemHeight) + (itemHeight * 0.5);

      final path = Path();
      path.moveTo(startX, startY);
      path.cubicTo(
        startX,
        startY + (endY - startY) * 0.5,
        endX,
        endY - (endY - startY) * 0.5,
        endX,
        endY,
      );

      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        double distance = 0;
        while (distance < metric.length) {
          final extractPath = metric.extractPath(distance, distance + 10);
          canvas.drawPath(extractPath, paint);
          distance += 20;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QuizPathPainter oldDelegate) =>
      oldDelegate.unlockedLevels != unlockedLevels ||
      oldDelegate.levelCount != levelCount;
}
