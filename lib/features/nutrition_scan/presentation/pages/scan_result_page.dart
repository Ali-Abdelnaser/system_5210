import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_5210/core/utils/app_images.dart';

class ScanResultPage extends StatelessWidget {
  final Map<String, double> nutritionValues;
  final int healthScore;
  final String confidence;
  final String explanation;
  final List<Map<String, dynamic>> breakdown;
  final List<String> detectedIngredients;
  final bool suitableForChildren;
  final String childAgeRange;
  final String medicalAdvice;
  final List<String> positives;
  final List<String> negatives;
  final bool isFromCache;
  final List<String> healthyAlternatives;
  final String system5210Impact;
  final String heroMessage;
  final DateTime? timestamp;

  const ScanResultPage({
    super.key,
    required this.nutritionValues,
    required this.healthScore,
    required this.confidence,
    required this.explanation,
    this.breakdown = const [],
    this.detectedIngredients = const [],
    this.suitableForChildren = true,
    this.childAgeRange = '',
    this.medicalAdvice = '',
    this.positives = const [],
    this.negatives = const [],
    this.isFromCache = false,
    this.healthyAlternatives = const [],
    this.system5210Impact = '',
    this.heroMessage = '',
    this.timestamp,
  });

  String _getScoreLabel(AppLocalizations l10n) {
    if (healthScore >= 80) return l10n.excellentChoice;
    if (healthScore >= 60) return l10n.goodChoice;
    if (healthScore >= 40) return l10n.averageChoice;
    return l10n.unhealthyChoice;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 320,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.appBlue, Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          l10n.scanResultTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildHeroScore(l10n),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMotherSummaryCard(l10n),
                      const SizedBox(height: 24),
                      _buildChildSafetyCard(l10n),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        l10n.nutritionFacts,
                        Icons.analytics_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildNutrientGrid(l10n),
                      const SizedBox(height: 24),
                      if (healthyAlternatives.isNotEmpty) ...[
                        _buildAlternativesSection(l10n),
                        const SizedBox(height: 24),
                      ],
                      if (medicalAdvice.isNotEmpty) ...[
                        _buildMedicalAdviceCard(l10n),
                        const SizedBox(height: 24),
                      ],
                      _buildDisclaimerSection(l10n),
                      const SizedBox(height: 40),
                      _buildActionFooter(context, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(top: 50, left: 20, child: const AppBackButton()),
        ],
      ),
    );
  }

  Widget _buildHeroScore(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: healthScore.toDouble()),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutExpo,
              builder: (context, value, child) {
                return Text(
                  "${value.toInt()}",
                  style: GoogleFonts.cairo(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                );
              },
            ),
            Text(
              "%",
              style: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            _getScoreLabel(l10n),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotherSummaryCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppTheme.appBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    heroMessage,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                if (system5210Impact.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.appYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      system5210Impact,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSafetyCard(AppLocalizations l10n) {
    final Color accentColor = suitableForChildren
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: suitableForChildren
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppImages.iconChild,
            colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
            width: 32,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.childSafetyTitle,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: accentColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  suitableForChildren
                      ? l10n.safeForChildren
                      : l10n.notSafeForChildren,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientGrid(AppLocalizations l10n) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemCount: nutritionValues.length,
      itemBuilder: (context, index) {
        final entry = nutritionValues.entries.elementAt(index);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getLocalLabel(l10n, entry.key),
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                "${entry.value.toInt()} ${entry.key == 'calories' ? l10n.kcal : l10n.gram}",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.localeName == 'ar'
              ? "بدائل صحية للعائلة"
              : "Family Health Alternatives",
          Icons.eco_outlined,
        ),
        const SizedBox(height: 16),
        ...healthyAlternatives.map(
          (alt) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.appGreen.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.appGreen,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alt,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalAdviceCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF475569),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.medicalAdviceTitle,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            medicalAdvice,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          l10n.localeName == 'ar'
              ? "هذا التحليل استرشادي فقط ولا يغني عن استشارة المختصين."
              : "This analysis is for guidance only and does not replace professional advice.",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, AppLocalizations l10n) {
    bool isFromHistory = timestamp != null;
    return Row(
      children: [
        if (isFromHistory)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _deleteResult(context, l10n),
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: Text(
                l10n.localeName == 'ar' ? "حذف الفحص" : "Delete Scan",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _saveResult(context, l10n),
              icon: const Icon(Icons.save_outlined),
              label: Text(
                l10n.save,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _deleteResult(BuildContext context, AppLocalizations l10n) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && timestamp != null) {
      AppAlerts.showCustomDialog(
        context,
        title: l10n.localeName == 'ar' ? "حذف الفحص" : "Delete Scan",
        message: l10n.localeName == 'ar'
            ? "هل أنت متأكد من حذف هذا الفحص من السجل؟"
            : "Are you sure you want to delete this scan from history?",
        buttonText: l10n.localeName == 'ar' ? "حذف" : "Delete",
        isSuccess: false,
        cancelText: l10n.cancel,
        onPressed: () {
          Navigator.pop(context);
          context.read<NutritionScanCubit>().deleteScanResult(
            user.uid,
            timestamp!,
          );
          Navigator.pop(context);
        },
      );
    }
  }

  void _saveResult(BuildContext context, AppLocalizations l10n) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = NutritionResult(
        id: '',
        userId: user.uid,
        timestamp: DateTime.now(),
        nutritionValues: nutritionValues,
        healthScore: healthScore,
        confidenceLevel: confidence,
        explanation: explanation,
        positives: positives,
        negatives: negatives,
        suitableForChildren: suitableForChildren,
        childAgeRange: childAgeRange,
        medicalAdvice: medicalAdvice,
        healthScoreReason: explanation,
        healthyAlternatives: healthyAlternatives,
        system5210Impact: system5210Impact,
        heroMessage: heroMessage,
        isApproximate: false,
      );
      context.read<NutritionScanCubit>().saveScanResult(result);
      AppAlerts.showAlert(
        context,
        message: l10n.saveSuccess,
        type: AlertType.success,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted)
          context.read<NutritionScanCubit>().loadRecentScans(user.uid);
      });
      Navigator.pop(context);
    }
  }

  String _getLocalLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'calories':
        return l10n.calories;
      case 'sugar':
        return l10n.sugar;
      case 'total_fat':
        return l10n.totalFat;
      case 'saturated_fat':
        return l10n.saturatedFat;
      case 'protein':
        return l10n.protein;
      case 'fiber':
        return l10n.fiber;
      case 'sodium':
        return l10n.sodium;
      case 'carbohydrates':
        return l10n.carbohydrates;
      default:
        return key;
    }
  }
}
