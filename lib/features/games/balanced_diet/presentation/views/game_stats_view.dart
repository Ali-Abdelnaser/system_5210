import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import '../cubit/game_stats_cubit.dart';
import '../cubit/game_stats_state.dart';
import '../widgets/game_stat_card.dart';
import '../widgets/game_history_item.dart';
import '../widgets/empty_history_widget.dart';

class GameStatsView extends StatefulWidget {
  const GameStatsView({super.key});

  @override
  State<GameStatsView> createState() => _GameStatsViewState();
}

class _GameStatsViewState extends State<GameStatsView> {
  @override
  void initState() {
    super.initState();
    context.read<GameStatsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'إحصائيات اللعبة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
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
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Summary Cards
                            _buildSummaryRow(state.stats),

                            const SizedBox(height: 30),

                            // History Section Header
                            _buildSectionHeader(
                              Icons.history_rounded,
                              'سجل المحاولات',
                            ),

                            const SizedBox(height: 15),

                            // History Content
                            if (state.history.isEmpty)
                              const EmptyHistoryWidget()
                            else
                              ...state.history.map(
                                (result) => GameHistoryItem(result: result),
                              ),

                            const SizedBox(height: 30),
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
            icon: Icons.sports_esports_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GameStatCard(
            label: 'طبق متوازن',
            value: '${stats.balancedPlays}',
            color: AppTheme.appGreen,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GameStatCard(
            label: 'غير متوازن',
            value: '${stats.unbalancedPlays}',
            color: AppTheme.appRed,
            icon: Icons.error_rounded,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D3142)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
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
          ElevatedButton(
            onPressed: () => context.read<GameStatsCubit>().loadStats(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
