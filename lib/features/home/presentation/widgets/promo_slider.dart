import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/views/daily_tasks_view.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'dart:ui';

class PromoSlider extends StatelessWidget {
  const PromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final List<Map<String, dynamic>> slides = [
      {
        "title": isAr ? "لعبة الطبق المتوازن" : "Balanced Plate",
        "text": isAr
            ? "رتب طبقك بالأكل الصحي الملون!"
            : "Fill your plate with colorful healthy food!",
        "badge": "GAME 1",
        "colors": [AppTheme.appRed, const Color(0xFFFF6B6B)],
        "mainAsset": AppImages.plate,
        "floatingAssets": [
          AppImages.apple,
          AppImages.broccoli,
          AppImages.carrots,
        ],
        "type": "plate",
        "route": AppRoutes.balancedPlateGame,
      },
      {
        "title": isAr ? "تحدي التوصيل" : "Connect Match",
        "text": isAr
            ? "وصل الأكلات المتشابهة بأسرع وقت!"
            : "Match the similar foods as fast as you can!",
        "badge": "GAME 2",
        "colors": [AppTheme.appYellow, const Color(0xFFFDCB6E)],
        "mainAsset": AppImages.connect,
        "type": "connect",
        "route": AppRoutes.matchingGame,
      },
      {
        "title": isAr ? "أرض التحديات" : "Quest Islands",
        "text": isAr
            ? "خض غمار المغامرة في جزر المعرفة!"
            : "Embark on a journey through knowledge islands!",
        "badge": "GAME 3",
        "colors": [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
        "mainAsset": AppImages.island,
        "type": "quiz",
        "route": AppRoutes.quizGame,
      },
      {
        "title": isAr ? "لعبة الترابط" : "Bonding Game",
        "text": isAr
            ? "تحديات ممتعة تجمعك أنت وأهلك!"
            : "Fun challenges for you and your family!",
        "badge": "GAME 4",
        "colors": [AppTheme.appGreen, const Color(0xFF55E6C1)],
        "mainAsset": AppImages.challengeParent,
        "secondaryAsset": AppImages.challengeChild,
        "type": "bonding",
        "route": AppRoutes.bondingGame,
      },
      {
        "title": isAr ? "الـ 6 مهام اليومية" : "6 Daily Missions",
        "text": isAr
            ? "أنجز مهامك الـ 6 لتبني عاداتك الصحية!"
            : "Complete 6 tasks to build your healthy habits!",
        "badge": "GAME 5",
        "colors": [AppTheme.appBlue, const Color.fromARGB(255, 83, 157, 231)],
        "mainAsset": AppImages.island,
        "secondaryAsset": AppImages.gameSuccess1,
        "type": "tasks",
        "route": null, // Special case for DailyTasksView
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 210,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
        autoPlayInterval: const Duration(seconds: 8),
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        autoPlayCurve: Curves.easeInOutQuart,
      ),
      items: slides.map((slide) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                if (slide['route'] != null) {
                  Navigator.pushNamed(context, slide['route']);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyTasksView(),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: (slide['colors'][0] as Color).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: slide['colors'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -40,
                        right: -40,
                        child: _buildBlurCircle(slide['colors'][0], 150),
                      ),
                      _buildGameComposition(slide, isAr),
                      _buildPosterContent(slide, isAr, context),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildGameComposition(Map<String, dynamic> slide, bool isAr) {
    switch (slide['type']) {
      case 'plate':
        return Stack(
          children: [
            Positioned(
              right: isAr ? null : -30,
              left: isAr ? -30 : null,
              bottom: -20,
              child: Image.asset(
                slide['mainAsset'],
                height: 180,
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 15.seconds),
            ),
            ...List.generate(3, (i) {
              return Positioned(
                right: isAr ? null : (20.0 + i * 40),
                left: isAr ? (20.0 + i * 40) : null,
                bottom: 30.0 + i * 20,
                child: Image.asset(slide['floatingAssets'][i], height: 45)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: 0,
                      end: -12,
                      duration: (2 + i * 0.8).seconds,
                      curve: Curves.easeInOutSine,
                    )
                    .rotate(begin: -0.1, end: 0.1, duration: 3.seconds),
              );
            }),
          ],
        );
      case 'connect':
        return Positioned(
          right: isAr ? null : -20,
          left: isAr ? -20 : null,
          bottom: 10,
          child: Image.asset(slide['mainAsset'], height: 160)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 3.seconds,
                curve: Curves.easeInOutQuad,
              ),
        );
      case 'quiz':
        return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  right: isAr ? null : 0,
                  left: isAr ? -10 : null,
                  bottom: -35,
                  child: Image.asset(AppImages.island, height: 170),
                ),
                Positioned(
                  right: isAr ? null : 20,
                  left: isAr ? 20 : null,
                  bottom: 65,
                  child: Image.asset(AppImages.gameSuccess1, height: 130),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -10,
              duration: 2.seconds,
              curve: Curves.easeInOutSine,
            );
      case 'bonding':
        return Stack(
              children: [
                Positioned(
                  right: isAr ? null : 0,
                  left: isAr ? 0 : null,
                  bottom: 0,
                  child: Image.asset(slide['mainAsset'], height: 200),
                ),
                Positioned(
                  right: isAr ? null : 60,
                  left: isAr ? 60 : null,
                  bottom: 10,
                  child: Image.asset(slide['secondaryAsset'], height: 180),
                ),
              ],
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 3.seconds,
              curve: Curves.easeInOutCubic,
            );
      case 'tasks':
        return Stack(
          children: [
            // Character 4 (Back leftmost in the group)
            Positioned(
              right: isAr ? null : 115,
              left: isAr ? 115 : null,
              bottom: 45,
              child: Image.asset(AppImages.gameSuccess4, height: 90)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -8, duration: 2.5.seconds),
            ),
            // Character 2 (Middle right)
            Positioned(
              right: isAr ? null : 15,
              left: isAr ? 15 : null,
              bottom: 60,
              child: Image.asset(AppImages.gameSuccess2, height: 105)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -12, duration: 3.seconds),
            ),
            // Character 3 (Front leftmost in the group)
            Positioned(
              right: isAr ? null : 65,
              left: isAr ? 65 : null,
              bottom: 5,
              child: Image.asset(AppImages.gameSuccess3, height: 125)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -10, duration: 2.2.seconds),
            ),
            // Character 1 (Front rightmost)
            Positioned(
              right: isAr ? null : -35,
              left: isAr ? -35 : null,
              bottom: -15,
              child: Image.asset(AppImages.gameSuccess1, height: 155)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -15, duration: 2.8.seconds),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPosterContent(
    Map<String, dynamic> slide,
    bool isAr,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
          end: isAr ? Alignment.centerLeft : Alignment.centerRight,
          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slide['badge'],
              style: GoogleFonts.poppins(
                color: slide['colors'][0],
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              slide['title'],
              style: GoogleFonts.dynaPuff(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text(
              slide['text'],
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          _buildPlayButton(slide['colors'][0]),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  Widget _buildPlayButton(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            "PLAY",
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}
