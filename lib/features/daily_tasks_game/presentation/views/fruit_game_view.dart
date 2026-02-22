import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../../../../core/widgets/app_back_button.dart';

class FruitGameView extends StatefulWidget {
  final VoidCallback onWin;

  const FruitGameView({super.key, required this.onWin});

  @override
  State<FruitGameView> createState() => _FruitGameViewState();
}

class _FruitGameViewState extends State<FruitGameView>
    with TickerProviderStateMixin {
  double basketX = 0.5;
  List<FallingItem> items = [];
  List<FlyingScoreEffect> effects = [];
  int healthyCaught = 0;
  int unhealthyCaught = 0;
  int score = 0;
  int timeLeft = 60;
  bool isGameOver = false;
  Timer? gameLoopTimer;
  Timer? countdownTimer;
  Timer? spawnTimer;
  final Random random = Random();
  final int targetScore = 50;

  double basketScale = 1.0;
  double scoreCardScale = 1.0;

  final List<String> healthyItems = [
    AppImages.apple,
    AppImages.broccoli,
    AppImages.carrots,
    AppImages.banana,
    AppImages.strawberry,
    AppImages.cucumber,
    AppImages.tomato,
    AppImages.orange,
    AppImages.grapes,
    AppImages.watermelon,
    AppImages.avocado,
    AppImages.pear,
  ];

  final List<String> unhealthyItems = [
    AppImages.burger,
    AppImages.pizza,
    AppImages.soda,
    AppImages.donut,
    AppImages.fries,
    AppImages.chips,
    AppImages.chocolate,
    AppImages.candy,
    AppImages.basbousa,
    AppImages.konafa,
    AppImages.cake,
    AppImages.iceCream,
  ];

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      score = 0;
      healthyCaught = 0;
      unhealthyCaught = 0;
      timeLeft = 60;
      isGameOver = false;
      items = [];
      effects = [];
    });

    gameLoopTimer?.cancel();
    countdownTimer?.cancel();
    spawnTimer?.cancel();

    // 16ms loop for smoother 60fps experience
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            endGame();
          }
        });
      }
    });

    spawnTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!isGameOver && mounted) {
        spawnItem();
      }
    });
  }

  void spawnItem() {
    bool isHealthy = random.nextDouble() > 0.4;
    String image = isHealthy
        ? healthyItems[random.nextInt(healthyItems.length)]
        : unhealthyItems[random.nextInt(unhealthyItems.length)];

    setState(() {
      items.add(
        FallingItem(
          x: random.nextDouble() * 0.9 + 0.05,
          y: -0.1,
          isHealthy: isHealthy,
          image: image,
        ),
      );
    });
  }

  void updateGame() {
    if (isGameOver) return;

    setState(() {
      // Update falling items
      for (var item in items) {
        if (item.isCaught) {
          item.y += 0.03;
          item.opacity -= 0.15;
          item.scale -= 0.15;
        } else {
          item.y += 0.007; // Slower falling speed
        }
      }

      // Update effects (Flying Scores)
      for (var effect in effects) {
        // Fly towards top-right (where the score card is)
        // Target is roughly (0.85, 0.05) in normalized screen space
        double targetX = 0.85;
        double targetY = 0.05;

        // Move towards target - slowed down for better visibility
        effect.x += (targetX - effect.x) * 0.06;
        effect.y += (targetY - effect.y) * 0.06;

        // Final impact check
        if ((effect.x - targetX).abs() < 0.05 &&
            (effect.y - targetY).abs() < 0.05) {
          if (!effect.hitTarget) {
            effect.hitTarget = true;
            _applyScoreChange(effect.value);
          }
        }
      }
      effects.removeWhere((e) => e.hitTarget);

      // Check collisions
      items.removeWhere((item) {
        if (!item.isCaught && item.y > 0.78 && item.y < 0.85) {
          double distance = (item.x - basketX).abs();
          if (distance < 0.18) {
            item.isCaught = true;
            _triggerBasketEffect();

            // Add flying score effect
            int val = item.isHealthy ? 10 : -15;
            if (item.isHealthy)
              healthyCaught++;
            else
              unhealthyCaught++;

            effects.add(
              FlyingScoreEffect(
                x: item.x,
                y: item.y,
                value: val,
                color: item.isHealthy ? Colors.green : Colors.red,
              ),
            );
          }
        }

        return item.y > 1.0 || (item.isCaught && item.opacity <= 0);
      });
    });
  }

  void _applyScoreChange(int val) {
    setState(() {
      score = max(0, score + val);
      scoreCardScale = 1.4;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => scoreCardScale = 1.0);
    });
  }

  void _triggerBasketEffect() {
    setState(() => basketScale = 1.3);
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => basketScale = 1.0);
    });
  }

  void endGame() {
    isGameOver = true;
    gameLoopTimer?.cancel();
    countdownTimer?.cancel();
    spawnTimer?.cancel();
    _showSummaryDialog();
  }

  void _showSummaryDialog() {
    final bool reachedTarget = score >= targetScore;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (reachedTarget ? AppTheme.appGreen : Colors.orange)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reachedTarget
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  color: reachedTarget ? AppTheme.appGreen : Colors.orange,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                reachedTarget ? 'عاش يا بطل!' : 'حاول مرة تانية',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: reachedTarget ? AppTheme.appGreen : Colors.orange,
                ),
              ),
              if (!reachedTarget)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'محتاج $targetScore نقطة عشان تعدي التحدي',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildStatRow('أكل صحي:', '$healthyCaught', Colors.green),
              _buildStatRow('حلويات:', '$unhealthyCaught', Colors.red),
              const Divider(),
              _buildStatRow(
                'المجموع:',
                '$score',
                AppTheme.appGreen,
                isBold: true,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        startGame();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.appGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'إعادة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.appGreen,
                        ),
                      ),
                    ),
                  ),
                  if (reachedTarget) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onWin();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.appGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'تم',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.black87),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    countdownTimer?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 10),

                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: AppTheme.appGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '00:${timeLeft.toString().padLeft(2, '0')}',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color: AppTheme.appGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AnimatedScale(
                        scale: scoreCardScale,
                        duration: const Duration(milliseconds: 100),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          child: Text(
                            'النقاط: $score',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              color: AppTheme.appGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        basketX += details.delta.dx / screenWidth;
                        basketX = basketX.clamp(0.1, 0.9);
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // Falling items
                          ...items.map(
                            (item) => Positioned(
                              left: item.x * screenWidth - (32 * item.scale),
                              top: item.y * screenHeight,
                              child: Opacity(
                                opacity: max(0, item.opacity),
                                child: Transform.scale(
                                  scale: max(0, item.scale),
                                  child: Image.asset(
                                    item.image,
                                    width: 75,
                                    height: 75,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Flying Score Effects
                          ...effects.map(
                            (effect) => Positioned(
                              left: effect.x * screenWidth - 20,
                              top: effect.y * screenHeight,
                              child:
                                  Text(
                                    (effect.value > 0 ? "+" : "") +
                                        effect.value.toString(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 42, // Much larger and visible
                                      fontWeight: FontWeight.w900,
                                      color: effect.color,
                                      shadows: [
                                        const Shadow(
                                          blurRadius: 10,
                                          color: Colors.white,
                                        ),
                                        Shadow(
                                          blurRadius: 5,
                                          color: effect.color.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ).animate().scale(
                                    begin: const Offset(0.5, 0.5),
                                    end: const Offset(1, 1),
                                  ),
                            ),
                          ),

                          // Basket
                          Positioned(
                            bottom: 50,
                            left: basketX * screenWidth - 60,
                            child: AnimatedScale(
                              scale: basketScale,
                              duration: const Duration(milliseconds: 80),
                              child: Icon(
                                Icons.shopping_basket_rounded,
                                size: 120,
                                color: AppTheme.appBlue.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FallingItem {
  double x;
  double y;
  bool isHealthy;
  String image;
  bool isCaught = false;
  double opacity = 1.0;
  double scale = 1.0;
  FallingItem({
    required this.x,
    required this.y,
    required this.isHealthy,
    required this.image,
  });
}

class FlyingScoreEffect {
  double x;
  double y;
  int value;
  Color color;
  bool hitTarget = false;
  FlyingScoreEffect({
    required this.x,
    required this.y,
    required this.value,
    required this.color,
  });
}
