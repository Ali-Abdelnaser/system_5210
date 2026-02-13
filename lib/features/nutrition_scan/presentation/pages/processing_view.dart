import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_state.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_result_page.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:system_5210/core/widgets/app_error_view.dart';

class ProcessingView extends StatefulWidget {
  final String imagePath;
  const ProcessingView({super.key, required this.imagePath});

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _scanController;
  int _tipIndex = 0;
  Timer? _tipTimer;
  bool _hasError = false;
  String _errorMessage = "";

  final List<String> _stepsEn = [
    "Analyzing image structure...",
    "Consulting AI experts...",
    "Checking pediatric safety...",
    "Drafting your report...",
  ];

  final List<String> _stepsAr = [
    "تجهيز وتحليل الصورة...",
    "استشارة الذكاء الاصطناعي...",
    "فحص معايير تغذية الأطفال...",
    "إعداد التقرير النهائي...",
  ];

  final List<String> _tipsAr = [
    "هل تعلمين؟ البروتين يساعد طفلك على بناء عضلات قوية!",
    "نصيحة: الأطعمة الغنية بالألياف تمنح شعوراً بالشبع لفترة أطول.",
    "سر الأمومة: نظام 5210 هو دليلك اليومي لصحة طفلك.",
    "هل تعلمين؟ شرب الماء بانتظام يحسن تركيز طفلك في المدرسة.",
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: 2.seconds)
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProcessing();
    });
    _startTipsRotation();
  }

  void _startTipsRotation() {
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && !_hasError)
        setState(() => _tipIndex = (_tipIndex + 1) % _tipsAr.length);
    });
  }

  void _startProcessing() async {
    if (!mounted) return;
    setState(() {
      _hasError = false;
      _currentStep = 0;
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      context.read<NutritionScanCubit>().analyzeImage(widget.imagePath, locale);
    } catch (e) {
      _handleLocalError(e.toString());
    }

    // Advance UI steps
    for (int i = 0; i <= 4; i++) {
      if (!mounted || _hasError) break;
      setState(() => _currentStep = i);
      HapticFeedback.lightImpact();

      if (_currentStep == 4) {
        _checkFinalState();
      } else {
        await Future.delayed(const Duration(milliseconds: 1800));
      }
    }
  }

  void _handleLocalError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  void _checkFinalState() {
    final state = context.read<NutritionScanCubit>().state;
    if (state is NutritionScanProcessed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(
            nutritionValues: state.nutritionValues,
            healthScore: state.healthScore,
            confidence: state.confidence,
            explanation: state.explanation,
            breakdown: state.breakdown,
            detectedIngredients: state.detectedIngredients,
            suitableForChildren: state.suitableForChildren,
            childAgeRange: state.childAgeRange,
            medicalAdvice: state.medicalAdvice,
            positives: state.positives,
            negatives: state.negatives,
            isFromCache: state.isFromCache,
            healthyAlternatives: state.healthyAlternatives,
            system5210Impact: state.system5210Impact,
            heroMessage: state.heroMessage,
          ),
        ),
      );
    } else if (state is NutritionScanError) {
      _handleLocalError(state.message);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context)!.localeName == 'ar';
    final steps = isAr ? _stepsAr : _stepsEn;

    return BlocListener<NutritionScanCubit, NutritionScanState>(
      listener: (context, state) {
        if (state is NutritionScanProcessed && _currentStep >= 4) {
          _checkFinalState();
        } else if (state is NutritionScanError) {
          _handleLocalError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black26),
              ),
            ),

            if (!_hasError) ...[
              // Scanning Beam
              _buildScanningBeam(),

              // Standard Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        isAr ? "دقيقة واحدة من فضلك..." : "Just a moment...",
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 12),
                      _buildTipSection(isAr),
                      const Spacer(),
                      _buildStepsList(steps),
                      const SizedBox(height: 30),
                      _buildProgressBar(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ] else
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(
                  color: Colors.white.withOpacity(0.95),
                  child: AppErrorView(
                    message: _errorMessage,
                    onRetry: _startProcessing,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningBeam() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * _scanController.value,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.appBlue.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipSection(bool isAr) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Text(
          _tipsAr[_tipIndex], // Mocking tips translated or separate lists
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppTheme.appYellow,
            height: 1.5,
          ),
        ).animate(key: ValueKey(_tipIndex)).fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildStepsList(List<String> steps) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      color: Colors.white.withOpacity(0.1),
      child: Column(
        children: List.generate(
          steps.length,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _buildStepCircle(i),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    steps[i],
                    style: GoogleFonts.cairo(
                      color: _currentStep >= i ? Colors.white : Colors.white38,
                      fontWeight: _currentStep == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_currentStep == i)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.appYellow,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int index) {
    bool done = _currentStep > index;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppTheme.appGreen
            : (_currentStep == index ? AppTheme.appBlue : Colors.white10),
        border: Border.all(color: Colors.white12),
      ),
      child: Center(
        child: Icon(
          done ? Icons.check : Icons.circle,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: _currentStep / 4,
        backgroundColor: Colors.white10,
        color: AppTheme.appBlue,
        minHeight: 6,
      ),
    ).animate().shimmer(duration: 2.seconds);
  }
}
