import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/game_center/data/models/user_points_model.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:system_5210/features/games/presentation/views/games_list_view.dart';
import 'package:system_5210/features/specialists/presentation/views/admin_login_view.dart';
import 'package:system_5210/core/widgets/profile_image_loader.dart';
import 'package:system_5210/features/games/presentation/views/wipe_progress_view.dart';

class GameCenterView extends StatefulWidget {
  const GameCenterView({super.key});

  @override
  State<GameCenterView> createState() => _GameCenterViewState();
}

class _GameCenterViewState extends State<GameCenterView> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            final now = DateTime.now();
            if (_lastTapTime == null ||
                now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
              _tapCount = 1;
            } else {
              _tapCount++;
            }
            _lastTapTime = now;

            if (_tapCount >= 4) {
              _tapCount = 0;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginView()),
              );
            }
          },
          child: Text(
            'مركز الأبطال',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WipeProgressView(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFF1565C0), // Blue color to make it pop
                  size: 24,
                ),
                tooltip: 'الإعدادات وحذف التقدم',
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Theme Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          BlocBuilder<UserPointsCubit, UserPointsState>(
            builder: (context, state) {
              if (state is UserPointsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserPointsLoaded) {
                return SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<UserPointsCubit>().init(),
                    color: AppTheme.appBlue,
                    backgroundColor: Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: [
                        // Total Score Summary Card (Profile Style Glass)
                        _buildSimpleSummary(state.points, state.userRank),

                        const SizedBox(height: 30),

                        // Points Breakdown - Dropdown Style

                        // Leaderboard Section
                        _buildSectionHeader(
                          'قائمة المتصدرين',
                          Icons.emoji_events_rounded,
                        ),
                        const SizedBox(height: 15),
                        _buildLeaderboard(state.topPlayers),

                        const SizedBox(height: 30),
                        _buildPointsDropdown(state.points),
                        const SizedBox(height: 35),

                        // Games Button - inside the page
                        _buildGamesButton(context),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('حدث خطأ في تحميل البيانات'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.appBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsDropdown(UserPointsModel points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('تفاصيل إنجازاتك', Icons.insights_rounded),
        const SizedBox(height: 5),
        _buildGlassMenuCard([
          Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.appBlue,
                  size: 24,
                ),
              ),
              title: Text(
                'عرض تفاصيل النقاط',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              children: [
                _buildPointRow(
                  'الطبق المتوازن',
                  points.balancedPlatePoints,
                  Icons.restaurant,
                  AppTheme.appGreen,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 40),
                _buildPointRow(
                  'لعبة التوصيل',
                  points.foodMatchingPoints,
                  Icons.extension,
                  AppTheme.appBlue,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 40),
                _buildPointRow(
                  'مغامرة المعرفة',
                  points.quizPoints,
                  Icons.psychology,
                  Colors.orange,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 40),
                _buildPointRow(
                  'تحدي الترابط',
                  points.bondingGamePoints,
                  Icons.people,
                  AppTheme.appRed,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 40),
                _buildPointRow(
                  'رحلة اليوم',
                  points.dailyJourneyPoints,
                  Icons.today,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildPointRow(String title, int value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 20),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF475569),
            ),
          ),
          const Spacer(),
          Text(
            '$value',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<LeaderboardEntry> players) {
    if (players.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Colors.amber.withOpacity(0.5),
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                'البحث عن الأبطال...',
                style: GoogleFonts.cairo(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (players.length >= 2)
            Expanded(child: _buildMagicalPodium(players[1], 2, 100)),

          // 1st Place (Center)
          if (players.length >= 1)
            Expanded(flex: 1, child: _buildMagicalPodium(players[0], 1, 150)),

          // 3rd Place
          if (players.length >= 3)
            Expanded(child: _buildMagicalPodium(players[2], 3, 80)),
        ],
      ),
    );
  }

  Widget _buildMagicalPodium(LeaderboardEntry player, int rank, double height) {
    final Color baseColor = rank == 1
        ? Colors.amber
        : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFB45309));

    final accentColor = rank == 1
        ? Colors.orange
        : (rank == 2 ? Colors.blue : Colors.deepOrange);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The Player Sphere
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Magic Circle / Orbit
            if (rank == 1)
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 140)
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 10.seconds)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  ),

            // Main Sphere
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [baseColor, accentColor.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ProfileImageLoader(
                  photoUrl: player.photoUrl,
                  displayName: player.name,
                  size: rank == 1 ? 110 : 80,
                  textSize: rank == 1 ? 32 : 26,
                ),
              ),
            ),

            // Top Decor (Crown/Star)
            Positioned(
              top: -30,
              child:
                  Icon(
                        rank == 1
                            ? Icons.workspace_premium_rounded
                            : Icons.star_rounded,
                        color: baseColor,
                        size: rank == 1 ? 45 : 30,
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -5, end: 5, duration: 1.5.seconds),
            ),
          ],
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 15),

        // 2. Name & Points Bubble (Glass Effect)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.cairo(
                      fontSize: rank == 1 ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${player.points} 🏆',
                    style: GoogleFonts.poppins(
                      fontSize: rank == 1 ? 13 : 11,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // 3. The Magical Pedestal (3D Block)
        Container(
          width: rank == 1 ? 100 : 85,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                baseColor.withOpacity(0.8),
                baseColor.withOpacity(0.3),
                baseColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Shine
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: const Icon(Icons.wb_sunny_rounded, size: 80)
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 5.seconds),
                ),
              ),
              // Big Rank Number
              Text(
                '$rank',
                style: GoogleFonts.poppins(
                  fontSize: rank == 1 ? 55 : 35,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.8),
                  shadows: [
                    Shadow(
                      color: baseColor.darker(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().shimmer(
          duration: 3.seconds,
          color: Colors.white.withOpacity(0.3),
        ),
      ],
    ).animate().slideY(
      begin: 0.5,
      end: 0,
      duration: 800.ms,
      curve: Curves.elasticOut,
    );
  }

  Widget _buildGlassMenuCard(List<Widget> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ),
    );
  }

  Widget _buildGamesButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.appBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamesListView()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.appBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              'انطلق للعب الآن',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  String _getRankName(int points) {
    if (points >= 5000) return 'المحارب الأسطوري 🎖️';
    if (points >= 3000) return 'البطل الخارق 🔥';
    if (points >= 1500) return 'الفارس الشجاع 🛡️';
    if (points >= 500) return 'المستكشف الذكي 🔍';
    return 'المبتدئ الطموح 🌱';
  }

  Widget _buildSimpleSummary(UserPointsModel points, int rank) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.appBlue,
                      size: 20,
                    ),
                    Text(
                      '#$rank',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appBlue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مجموع نقاطك',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${points.totalPoints}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.appGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppTheme.appGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRankName(points.totalPoints),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppTheme.appGreen,
                        fontWeight: FontWeight.bold,
                      ),
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

extension ColorExtension on Color {
  Color darker(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
