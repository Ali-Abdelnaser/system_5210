import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/theme/app_theme.dart';
import '../manager/daily_tasks_cubit.dart';
import '../manager/daily_tasks_state.dart';
import '../widgets/glass_card.dart';
import '../../data/models/daily_task_model.dart';
import 'task_camera_view.dart';
import 'fruit_game_view.dart';
import 'water_stage_view.dart';
import 'movement_stage_view.dart';
import 'sleep_stage_view.dart';

class DailyTasksView extends StatelessWidget {
  const DailyTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),

            // Content
            BlocBuilder<DailyTasksCubit, DailyTasksState>(
              builder: (context, state) {
                if (state is DailyTasksLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DailyTasksLoaded) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: state.isGameStarted
                        ? _buildProgressTracker(context, state)
                        : _buildStartScreen(context),
                  );
                } else if (state is DailyTasksFailure) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: GlassCard(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'استعد لليوم الجديد!',
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'عندك 6 مهام النهاردة، تقدر تخلصهم كلهم؟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.read<DailyTasksCubit>().startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ابدأ يومك',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().scale(
                delay: 400.ms,
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker(BuildContext context, DailyTasksLoaded state) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'مهام اليوم',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().slideY(begin: -0.2),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 25,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إنجاز اليوم',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.completedCount} / 6',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: state.totalProgress,
                            minHeight: 12,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.appRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(delay: 200.ms),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final task = state.tasks[index];
                return _buildTaskCard(context, task, index);
              }, childCount: state.tasks.length),
            ),
          ),

          if (state.completedCount == 6)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GlassCard(
                  color: Colors.green,
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'عاش يا بطل! خلصت كل مهام النهاردة',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, DailyTask task, int index) {
    return GestureDetector(
      onTap: () => _onTaskTap(context, task),
      child: GlassCard(
        opacity: task.isCompleted ? 0.3 : 0.1,
        color: task.isCompleted ? Colors.green : Colors.white,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTaskIcon(task.type),
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (task.isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 24,
              ).animate().scale(duration: 300.ms, curve: Curves.bounceOut),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1),
    );
  }

  IconData _getTaskIcon(DailyTaskType type) {
    switch (type) {
      case DailyTaskType.breakfast:
        return Icons.breakfast_dining;
      case DailyTaskType.fruitGame:
        return Icons.apple;
      case DailyTaskType.water:
        return Icons.local_drink;
      case DailyTaskType.movement:
        return Icons.directions_run;
      case DailyTaskType.lunch:
        return Icons.lunch_dining;
      case DailyTaskType.sleep:
        return Icons.bedtime;
    }
  }

  void _onTaskTap(BuildContext context, DailyTask task) {
    switch (task.type) {
      case DailyTaskType.breakfast:
      case DailyTaskType.lunch:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskCameraView(
              title: task.title,
              onPhotoTaken: (path) {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(isCompleted: true, imagePath: path),
                );
                Navigator.pop(context);
              },
            ),
          ),
        );
        break;
      case DailyTaskType.fruitGame:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FruitGameView(
              onWin: () {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(isCompleted: true),
                );
              },
            ),
          ),
        );
        break;
      case DailyTaskType.water:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WaterStageView(
              onComplete: () {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(isCompleted: true),
                );
              },
            ),
          ),
        );
        break;
      case DailyTaskType.movement:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovementStageView(
              onComplete: () {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(isCompleted: true),
                );
              },
            ),
          ),
        );
        break;
      case DailyTaskType.sleep:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SleepStageView(
              startTime: task.sleepStartTime,
              wakeTime: task.wakeUpTime,
              onStartSleep: (start) {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(sleepStartTime: start),
                );
              },
              onWakeUp: (wake, advice) {
                context.read<DailyTasksCubit>().updateTask(
                  task.copyWith(wakeUpTime: wake, isCompleted: true),
                );
              },
            ),
          ),
        );
        break;
    }
  }
}
