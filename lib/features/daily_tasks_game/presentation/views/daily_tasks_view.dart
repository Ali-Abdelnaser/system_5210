import 'dart:io';
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
import '../../../../core/widgets/app_back_button.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';

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
                  return SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const AppBackButton(),
                              const Spacer(),
                              AppShimmer(width: 150, height: 30),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: 6,
                            itemBuilder: (_, __) => AppShimmer.taskGridCard(),
                          ),
                        ),
                      ],
                    ),
                  );
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
                  color: AppTheme.appGreen,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'عندك 6 مهام النهاردة، تقدر تخلصهم كلهم؟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppTheme.appGreen.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.read<DailyTasksCubit>().startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appGreen,
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
                      const AppBackButton(),
                      const Spacer(),
                      Text(
                        'مهام اليوم',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.appGreen,
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
                                color: AppTheme.appGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${state.completedCount} / 6',
                              style: GoogleFonts.cairo(
                                color: AppTheme.appGreen,
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
                            backgroundColor: AppTheme.appGreen.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.appGreen,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'عاش يا بطل! خلصت كل مهام النهاردة',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
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
        color: task.isCompleted
            ? AppTheme.appGreen.withOpacity(0.3)
            : Colors.white,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.appGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTaskIcon(task.type),
                size: 40,
                color: AppTheme.appGreen,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.appGreen,
              ),
            ),
            if (task.isCompleted)
              const Icon(
                Icons.check_circle,
                color: AppTheme.appGreen,
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
        if (task.isCompleted && task.imagePath != null) {
          _showPhotoSummary(context, task);
        } else {
          _openCamera(context, task);
        }
        break;
      case DailyTaskType.fruitGame:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DailyTasksCubit>(),
              child: FruitGameView(
                onWin: () {
                  context.read<DailyTasksCubit>().updateTask(
                    task.copyWith(isCompleted: true),
                  );
                },
              ),
            ),
          ),
        );
        break;
      case DailyTaskType.water:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DailyTasksCubit>(),
              child: WaterStageView(
                onComplete: () {
                  context.read<DailyTasksCubit>().updateTask(
                    task.copyWith(isCompleted: true),
                  );
                },
              ),
            ),
          ),
        );
        break;
      case DailyTaskType.movement:
        if (task.isCompleted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DailyTasksCubit>(),
              child: MovementStageView(
                onComplete: () {
                  context.read<DailyTasksCubit>().updateTask(
                    task.copyWith(isCompleted: true),
                  );
                },
              ),
            ),
          ),
        );
        break;
      case DailyTaskType.sleep:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DailyTasksCubit>(),
              child: const SleepStageView(),
            ),
          ),
        );
        break;
    }
  }

  void _openCamera(BuildContext context, DailyTask task) {
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
  }

  void _showPhotoSummary(BuildContext context, DailyTask task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'شوف إنت أكلت إيه!',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.appGreen,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),

              // Image in a Frame
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.appGreen.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: AppTheme.appGreen, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(task.imagePath!),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeInOut),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _openCamera(context, task);
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'تصوير تاني',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'تمام',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appGreen,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  context.read<DailyTasksCubit>().updateTask(
                    task.copyWith(isCompleted: false, imagePath: null),
                  );
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'مسح الصورة',
                  style: GoogleFonts.cairo(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
