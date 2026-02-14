import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/game_stats_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/game_stats_state.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/widgets/game_stat_card.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/widgets/empty_history_widget.dart';
import 'package:system_5210/features/games/food_matching/presentation/widgets/matching_history_item.dart';

class MatchingStatsView extends StatefulWidget {
  const MatchingStatsView({super.key});

  @override
  State<MatchingStatsView> createState() => _MatchingStatsViewState();
}

class _MatchingStatsViewState extends State<MatchingStatsView> {
  @override
  void initState() {
    super.initState();
    context.read<GameStatsCubit>().loadStats(gameId: 'food_matching');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'سجل الأذكياء',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    AppTheme.appBlue.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: BlocBuilder<GameStatsCubit, GameStatsState>(
              builder: (context, state) {
                if (state is GameStatsLoading) {
                  return const Center(child: AppLoadingIndicator());
                }

                if (state is GameStatsFailure) {
                  return _buildErrorState(state.message);
                }

                if (state is GameStatsLoaded) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Summary Header
                            Text(
                              'إنجازاتك في الربط الذكي',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF475569),
                              ),
                            ).animate().fadeIn(),

                            const SizedBox(height: 20),

                            // Summary Cards
                            _buildSummaryRow(state.stats),

                            const SizedBox(height: 35),

                            // History Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.appBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.history_edu_rounded,
                                    color: AppTheme.appBlue,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'تاريخك الذكي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ).animate().slideX(begin: -0.1, end: 0),

                            const SizedBox(height: 20),

                            if (state.history.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: EmptyHistoryWidget(),
                              )
                            else
                              ...state.history.map(
                                (result) => MatchingHistoryItem(result: result),
                              ),

                            const SizedBox(height: 40),
                          ]),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: GameStatCard(
            label: 'إجمالي المرات',
            value: '${stats.totalPlays}',
            color: AppTheme.appBlue,
            icon: Icons.auto_graph_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GameStatCard(
            label: 'إتقان التوصيل',
            value: '${stats.stars3Count ?? 0}',
            color: AppTheme.appGreen,
            icon: Icons.workspace_premium_rounded,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.cairo(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<GameStatsCubit>().loadStats(
              gameId: 'food_matching',
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
