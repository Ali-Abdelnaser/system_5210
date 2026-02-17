import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import '../../data/models/healthy_insights_data.dart';
import '../widgets/insight_card.dart';

class HealthyInsightsView extends StatelessWidget {
  const HealthyInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'معلومات تهمك',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1E293B),
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
            child: Column(
              children: [
                // Header Illustration/Icon
                const SizedBox(height: 10),
                Center(
                  child:
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 50,
                          color: Color(0xFF3B82F6),
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),
                const SizedBox(height: 20),

                Text(
                  'دليلك لصحة طفلك وعائلتك',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),

                // Content List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: HealthyInsightsData.insights.length,
                    itemBuilder: (context, index) {
                      return InsightCard(
                            insight: HealthyInsightsData.insights[index],
                            index: index,
                          )
                          .animate()
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: (100 * index).ms,
                            duration: 500.ms,
                          )
                          .fadeIn();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
