import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_state.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_result_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';

class RecentScansPage extends StatefulWidget {
  const RecentScansPage({super.key});

  @override
  State<RecentScansPage> createState() => _RecentScansPageState();
}

class _RecentScansPageState extends State<RecentScansPage> {
  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  void _loadScans() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<NutritionScanCubit>().loadRecentScans(user.uid);
    }
  }

  // Temporary Localization Helper until gen-l10n is run
  String _t(AppLocalizations l10n, String key) {
    bool isAr = l10n.localeName == 'ar';
    switch (key) {
      case 'recentScansTitle':
        return isAr ? "سجل الفحوصات" : "Scan History";
      case 'noScansTitle':
        return isAr ? "لا يوجد فحوصات بعد" : "No scans yet";
      case 'noScansDesc':
        return isAr
            ? "ابدأ بفحص المنتجات لتظهر هنا"
            : "Start scanning products to see them here";
      case 'tryAgain':
        return isAr ? "إعادة المحاولة" : "Try Again";
      case 'today':
        return isAr ? "اليوم" : "Today";
      case 'yesterday':
        return isAr ? "أمس" : "Yesterday";
      case 'warnings':
        return isAr ? "تنبيهات" : "warnings";
      case 'safe':
        return isAr ? "آمن" : "Safe";
      case 'warning':
        return isAr ? "تنبيه" : "Warning";
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _t(l10n, 'recentScansTitle'),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NutritionScanCubit, NutritionScanState>(
        builder: (context, state) {
          if (state is NutritionScanLoading) {
            return _buildShimmerLoading();
          }

          if (state is RecentScansLoaded || state is NutritionScanSuccess) {
            List<NutritionResult> scans = [];
            if (state is RecentScansLoaded) scans = state.scans;

            if (scans.isEmpty) {
              if (state is NutritionScanSuccess) {
                _loadScans();
              }
              return _buildEmptyState(l10n);
            }

            return RefreshIndicator(
              onRefresh: () async => _loadScans(),
              color: AppTheme.appBlue,
              backgroundColor: Colors.white,
              child: _buildGroupedList(scans, l10n),
            );
          }

          if (state is NutritionScanError) {
            return _buildErrorState(state.message, l10n);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildGroupedList(List<NutritionResult> scans, AppLocalizations l10n) {
    final Map<String, List<NutritionResult>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var scan in scans) {
      final scanDate = DateTime(
        scan.timestamp.year,
        scan.timestamp.month,
        scan.timestamp.day,
      );
      String key;

      if (scanDate == today) {
        key = _t(l10n, 'today');
      } else if (scanDate == yesterday) {
        key = _t(l10n, 'yesterday');
      } else {
        key = DateFormat('EEEE, d MMM', l10n.localeName).format(scan.timestamp);
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(scan);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final key = grouped.keys.elementAt(index);
        final dayScans = grouped[key]!;

        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Text(
                    key,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                ...dayScans.map((scan) => _buildScanCard(scan, l10n)).toList(),
              ],
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
            .slideY(begin: 0.1);
      },
    );
  }

  Widget _buildScanCard(NutritionResult scan, AppLocalizations l10n) {
    Color scoreColor = scan.healthScore >= 80
        ? const Color(0xFF10B981)
        : (scan.healthScore >= 50
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444));

    List<Color> gradientColors = scan.healthScore >= 80
        ? [Colors.white, const Color(0xFFF0FDF4)]
        : (scan.healthScore >= 50
              ? [Colors.white, const Color(0xFFFFFBEB)]
              : [Colors.white, const Color(0xFFFEF2F2)]);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: scoreColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResultPage(
                  nutritionValues: scan.nutritionValues,
                  healthScore: scan.healthScore,
                  confidence: scan.confidenceLevel,
                  explanation: scan.explanation,
                  positives: scan.positives,
                  negatives: scan.negatives,
                  suitableForChildren: scan.suitableForChildren,
                  childAgeRange: scan.childAgeRange,
                  medicalAdvice: scan.medicalAdvice,
                  detectedIngredients: scan.warnings,
                  isFromCache: true,
                  healthyAlternatives: scan.healthyAlternatives,
                  system5210Impact: scan.system5210Impact,
                  heroMessage: scan.heroMessage,
                  timestamp: scan.timestamp,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        value: scan.healthScore / 100,
                        backgroundColor: scoreColor.withOpacity(0.1),
                        color: scoreColor,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      "${scan.healthScore}",
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'hh:mm a',
                              l10n.localeName,
                            ).format(scan.timestamp),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scan.suitableForChildren
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  scan.suitableForChildren
                                      ? Icons.child_care
                                      : Icons.warning_amber_rounded,
                                  size: 14,
                                  color: scan.suitableForChildren
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF991B1B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  scan.suitableForChildren
                                      ? _t(l10n, 'safe')
                                      : _t(l10n, 'warning'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: scan.suitableForChildren
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scan.explanation.split('\n').first,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                      if (scan.warnings.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: AppTheme.appRed.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${scan.warnings.length} ${_t(l10n, 'warnings')}",
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: AppTheme.appRed.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.history_edu_outlined,
              size: 80,
              color: AppTheme.appBlue.withOpacity(0.5),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            _t(l10n, 'noScansTitle'),
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            _t(l10n, 'noScansDesc'),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppTheme.appRed.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadScans,
              icon: const Icon(Icons.refresh),
              label: Text(_t(l10n, 'tryAgain')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.appBlue,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) => AppShimmer.recentScanCard(),
    );
  }
}
