import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class WipeProgressView extends StatelessWidget {
  const WipeProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'إعادة ضبط التقدم',
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
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: BlocBuilder<UserPointsCubit, UserPointsState>(
              builder: (context, state) {
                if (state is UserPointsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),

                      // Individual Game Resets
                      _buildResetCard(
                        context,
                        title: 'الطبق المتوازن',
                        points: state is UserPointsLoaded
                            ? state.points.balancedPlatePoints
                            : 0,
                        gameId: 'balanced_plate',
                        icon: Icons.restaurant_rounded,
                        color: AppTheme.appGreen,
                      ),
                      const SizedBox(height: 16),

                      _buildResetCard(
                        context,
                        title: 'لعبة التوصيل',
                        points: state is UserPointsLoaded
                            ? state.points.foodMatchingPoints
                            : 0,
                        gameId: 'food_matching',
                        icon: Icons.extension_rounded,
                        color: AppTheme.appBlue,
                      ),
                      const SizedBox(height: 16),

                      _buildResetCard(
                        context,
                        title: 'مغامرة المعلومات (الكويز)',
                        points: state is UserPointsLoaded
                            ? state.points.quizPoints
                            : 0,
                        gameId: 'quiz',
                        icon: Icons.psychology_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),

                      _buildResetCard(
                        context,
                        title: 'لعبة الترابط',
                        points: state is UserPointsLoaded
                            ? state.points.bondingGamePoints
                            : 0,
                        gameId: 'bonding',
                        icon: Icons.people_alt_rounded,
                        color: AppTheme.appRed,
                      ),
                      const SizedBox(height: 16),

                      _buildResetCard(
                        context,
                        title: 'رحلة اليوم',
                        points: state is UserPointsLoaded
                            ? state.points.dailyJourneyPoints
                            : 0,
                        gameId: 'daily_journey',
                        icon: Icons.today_rounded,
                        color: Colors.purple,
                      ),

                      const SizedBox(height: 40),

                      // Wipe All Button
                      _buildWipeAllButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'تحكم في تقدمك',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك تصفير نقاط ومراحل كل لعبة على حدا، أو مسح كل البيانات والبدء من جديد.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildResetCard(
    BuildContext context, {
    required String title,
    required int points,
    required String gameId,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'النقاط المتوفرة: $points',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _confirmReset(context, title, gameId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  'تصفير',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  void _confirmReset(BuildContext context, String title, String gameId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تأكيد تصفير $title',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد؟ سيتم مسح نقاط هذه اللعبة وتقدمك فيها نهائياً.',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserPointsCubit>().resetSpecificGameProgress(gameId);
              Navigator.pop(ctx);
              AppAlerts.showAlert(
                context,
                message: 'تم تصفير $title بنجاح',
                type: AlertType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'تصفير الآن',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWipeAllButton(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _confirmWipeAll(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'مسح كل التقدم والنقاط',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmWipeAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'مسح كلي شامل!',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'أنت على وشك مسح كل إنجازاتك في كل الألعاب وتصفير نقاطك تماماً. لا يمكن التراجع عن هذا الفعل.',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('تراجع', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserPointsCubit>().wipeCurrentUserData();
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to games list
              AppAlerts.showAlert(
                context,
                message: 'تم مسح كل البيانات بنجاح',
                type: AlertType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'تأكيد المسح الكلي',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
