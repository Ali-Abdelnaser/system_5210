import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../manager/daily_tasks_cubit.dart';
import '../manager/daily_tasks_state.dart';
import '../../data/models/daily_task_model.dart';

class SleepStageView extends StatefulWidget {
  const SleepStageView({super.key});

  @override
  State<SleepStageView> createState() => _SleepStageViewState();
}

class _SleepStageViewState extends State<SleepStageView> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready to read the cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDuration();
      _startTimer();
    });
  }

  void _updateDuration() {
    if (!mounted) return;
    final state = context.read<DailyTasksCubit>().state;
    if (state is DailyTasksLoaded) {
      final sleepTask = state.tasks.firstWhere(
        (t) => t.type == DailyTaskType.sleep,
      );
      if (sleepTask.sleepStartTime != null && sleepTask.wakeUpTime == null) {
        setState(() {
          _duration = DateTime.now().difference(sleepTask.sleepStartTime!);
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDuration();
    });
  }

  String _calculateAdvice(DateTime start, DateTime wake) {
    final hours = wake.difference(start).inHours;
    if (hours < 7) {
      return 'نومك قليل يا بطل، حاول تنام بدري أكتر عشان جسمك يرتاح ويكبر.';
    } else if (hours > 10) {
      return 'نمت كتير النهاردة! النوم الكتير بيخلي الجسم كسلان، خير الأمور الوسط.';
    } else {
      return 'نوم مثالي! عاش يا بطل، كدة جسمك أخد وقته في الراحة.';
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyTasksCubit, DailyTasksState>(
      builder: (context, state) {
        if (state is! DailyTasksLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final sleepTask = state.tasks.firstWhere(
          (t) => t.type == DailyTaskType.sleep,
        );
        final bool isSleeping =
            sleepTask.sleepStartTime != null && sleepTask.wakeUpTime == null;
        final bool isDone = sleepTask.wakeUpTime != null;

        // Update duration if already done
        if (isDone && sleepTask.sleepStartTime != null) {
          _duration = sleepTask.wakeUpTime!.difference(
            sleepTask.sleepStartTime!,
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [const AppBackButton(), const Spacer()],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'تحدي النوم الهادئ',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appGreen,
                      ),
                      textDirection: TextDirection.rtl,
                    ),

                    if (isSleeping)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'أنت الآن في عالم الأحلام',
                                style: GoogleFonts.cairo(
                                  color: AppTheme.appGreen.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.appGreen,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                      ),

                    const Spacer(),

                    Center(
                      child: Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          color: (isSleeping ? Colors.indigo : Colors.orange)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(
                                  isSleeping
                                      ? Icons.nights_stay_rounded
                                      : Icons.wb_sunny_rounded,
                                  size: 140,
                                  color: isSleeping
                                      ? Colors.indigoAccent
                                      : Colors.orangeAccent,
                                )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  duration: 2.seconds,
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1.1, 1.1),
                                )
                                .shimmer(delay: 3.seconds, duration: 2.seconds),
                      ),
                    ),

                    const Spacer(),

                    if (!isSleeping && !isDone)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<DailyTasksCubit>().updateTask(
                              sleepTask.copyWith(
                                sleepStartTime: DateTime.now(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.appGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bed_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ' تصبحوا على خير',
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
                      ).animate().slideY(begin: 0.5),

                    if (isSleeping)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<DailyTasksCubit>().updateTask(
                              sleepTask.copyWith(
                                wakeUpTime: DateTime.now(),
                                isCompleted: true,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wb_sunny_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ' صباح الخير',
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
                      ).animate().slideY(begin: 0.5),

                    if (isDone)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: GlassCard(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppTheme.appGreen,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'وقت النوم الإجمالي: ${_formatDuration(_duration)}',
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.appGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _calculateAdvice(
                                  sleepTask.sleepStartTime!,
                                  sleepTask.wakeUpTime!,
                                ),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.appGreen,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'تم المهمة',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().scale(),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
