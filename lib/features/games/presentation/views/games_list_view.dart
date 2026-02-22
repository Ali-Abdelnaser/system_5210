import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:provider/provider.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/manager/daily_tasks_cubit.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/views/daily_tasks_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamesListView extends StatelessWidget {
  const GamesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'أرض الألعاب',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142), // Dark color for better contrast
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildGameCard(
                  context,
                  title: 'الطبق المتوازن',
                  description: 'ساعد بطلنا في اختيار وجبة صحية ولذيذة',
                  imagePath: AppImages.plate,
                  color: AppTheme.appGreen,
                  routeName: AppRoutes.balancedPlateGame,
                  statsRouteName: AppRoutes.balancedPlateStats,
                  showStats: true,
                ).animate().slideX(
                  begin: -1,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 20),

                _buildGameCard(
                  context,
                  title: 'لعبة التوصيل الذكية',
                  description: 'وصل الكلمات بصورها المناسبة بذكاء وسرعة',
                  imagePath: AppImages.connect,
                  color: AppTheme.appBlue,
                  routeName: AppRoutes.matchingGame,
                  statsRouteName: AppRoutes.matchingStats,
                  showStats: true,
                ).animate().slideX(
                  begin: 1,
                  end: 0,
                  delay: 200.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 20),

                _buildGameCard(
                  context,
                  title: 'مغامرة المعلومات',
                  description: 'تحدى نفسك في 14 مستوي من الأسئلة المشوقة',
                  imagePath: AppImages
                      .quiz, // Using connect image for now or something else
                  color: Colors.orange,
                  routeName: AppRoutes.quizGame,
                  statsRouteName: AppRoutes.quizGame,
                  showStats: false,
                ).animate().slideX(
                  begin: -1,
                  end: 0,
                  delay: 400.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 20),

                _buildGameCard(
                  context,
                  title: 'لعبة الترابط',
                  description:
                      'تحديات يومية تجمع الطفل والأهل لتعزيز الروابط الصحية',
                  imagePath: AppImages
                      .challengeParent, // Using header image or similar
                  color: AppTheme.appBlue,
                  routeName: AppRoutes.bondingGame,
                  statsRouteName: AppRoutes.bondingGame,
                  showStats: false,
                ).animate().slideX(
                  begin: 1,
                  end: 0,
                  delay: 600.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 20),

                _buildGameCard(
                  context,
                  title: 'رحلة اليوم',
                  description: 'خلص 6 مهام واكسب التحدي اليومي!',
                  imagePath: AppImages.character4, // Placeholder character
                  color: AppTheme.appRed,
                  routeName: '', // Not used for custom navigation
                  statsRouteName: '',
                  showStats: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<DailyTasksCubit>(),
                        child: const DailyTasksView(),
                      ),
                    ),
                  ),
                ).animate().slideX(
                  begin: -1,
                  end: 0,
                  delay: 800.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required String imagePath,
    required Color color,
    required String routeName,
    required String statsRouteName,
    required bool showStats,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, routeName),
      child: GlassContainer(
        blur: 10,
        opacity: 0.6,
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // Game Icon/Thumbnail
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),

              const SizedBox(width: 20),

              // Game Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color(0xFF475569),
                        height: 1.3,
                      ),
                    ),
                    if (showStats)
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, statsRouteName),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'الإحصائيات والسجل',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // Play Icon
              Icon(Icons.play_circle_fill_rounded, color: color, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
