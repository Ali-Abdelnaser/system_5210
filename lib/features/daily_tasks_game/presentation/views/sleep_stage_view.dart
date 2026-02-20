import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SleepStageView extends StatefulWidget {
  final DateTime? startTime;
  final DateTime? wakeTime;
  final Function(DateTime start) onStartSleep;
  final Function(DateTime wake, String advice) onWakeUp;

  const SleepStageView({
    super.key,
    this.startTime,
    this.wakeTime,
    required this.onStartSleep,
    required this.onWakeUp,
  });

  @override
  State<SleepStageView> createState() => _SleepStageViewState();
}

class _SleepStageViewState extends State<SleepStageView> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  String advice = '';

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null && widget.wakeTime == null) {
      _startTimer();
    } else if (widget.wakeTime != null) {
      _calculateFinalAdvice();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.startTime != null) {
        setState(() {
          _duration = DateTime.now().difference(widget.startTime!);
        });
      }
    });
  }

  void _calculateFinalAdvice() {
    if (widget.startTime != null && widget.wakeTime != null) {
      final hours = widget.wakeTime!.difference(widget.startTime!).inHours;
      if (hours < 7) {
        advice = 'نومك قليل يا بطل، حاول تنام بدري أكتر عشان جسمك يرتاح ويكبر.';
      } else if (hours > 10) {
        advice =
            'نمت كتير النهاردة! النوم الكتير بيخلي الجسم كسلان، خير الأمور الوسط.';
      } else {
        advice = 'نوم مثالي! عاش يا بطل، كدة جسمك أخد وقته في الراحة.';
      }
      _duration = widget.wakeTime!.difference(widget.startTime!);
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
    bool isSleeping = widget.startTime != null && widget.wakeTime == null;
    bool isDone = widget.wakeTime != null;

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
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                if (isSleeping)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'وقت النوم الآن',
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.5),

                const Spacer(),

                Center(
                  child:
                      Icon(
                            isSleeping ? Icons.nights_stay : Icons.wb_sunny,
                            size: 150,
                            color: isSleeping
                                ? Colors.indigoAccent
                                : Colors.orangeAccent,
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            duration: 2.seconds,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                          ),
                ),

                const Spacer(),

                if (!isSleeping && !isDone)
                  ElevatedButton(
                    onPressed: () {
                      widget.onStartSleep(DateTime.now());
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'أنا هنام دلوقتي تصبحوا على خير',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (isSleeping)
                  ElevatedButton(
                    onPressed: () {
                      final wakeTime = DateTime.now();
                      _timer?.cancel();
                      _calculateFinalAdvice();
                      widget.onWakeUp(wakeTime, advice);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'أنا صحيت خلاص صباح الخير',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (isDone)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GlassCard(
                      child: Column(
                        children: [
                          Text(
                            'وقت النوم الإجمالي: ${_formatDuration(_duration)}',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            advice,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.appRed,
                            ),
                            child: Text(
                              'رجوع للمهام',
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().scale(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
