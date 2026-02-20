import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_images.dart';
import '../widgets/glass_card.dart';

class FruitGameView extends StatefulWidget {
  final VoidCallback onWin;

  const FruitGameView({super.key, required this.onWin});

  @override
  State<FruitGameView> createState() => _FruitGameViewState();
}

class _FruitGameViewState extends State<FruitGameView> {
  double basketX = 0;
  List<FallingItem> items = [];
  int score = 0;
  int missedHealth = 0;
  int caughtUnhealthy = 0;
  bool isGameOver = false;
  Timer? gameTimer;
  final Random random = Random();

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
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      updateGame();
    });

    // Spawn items periodically
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      spawnItem();
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
          x: random.nextDouble() * 0.8 + 0.1,
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
      for (var item in items) {
        item.y += 0.015; // Gravity
      }

      // Check collisions
      items.removeWhere((item) {
        if (item.y > 0.85 && (item.x - basketX).abs() < 0.2) {
          if (item.isHealthy) {
            score++;
          } else {
            caughtUnhealthy++;
            score = max(0, score - 2);
          }
          return true;
        }

        if (item.y > 1.0) {
          if (item.isHealthy) missedHealth++;
          return true;
        }
        return false;
      });

      // Winning condition: Reach 20 points
      if (score >= 20) {
        isGameOver = true;
        gameTimer?.cancel();
        _showSuccessDialog();
      }

      // Losing condition (Optional): Too many mistakes
      if (caughtUnhealthy >= 10) {
        isGameOver = true;
        gameTimer?.cancel();
        _showGameOverDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'عاش يا بطل!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'جمعت كل الخضروات والفاكهة ووصلت للهدف!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onWin();
              Navigator.pop(context); // Back to Tracker
            },
            child: Text(
              'رجوع',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'حاول تاني!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'أكلت حلويات كتيير، ركز في الخضروات أكتر!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                caughtUnhealthy = 0;
                items = [];
                isGameOver = false;
                startGame();
              });
            },
            child: Text(
              'جرب تاني',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (Same as others)
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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          'السكور: $score',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                        basketX +=
                            details.delta.dx /
                            MediaQuery.of(context).size.width;
                        basketX = basketX.clamp(-0.4, 0.4);
                      });
                    },
                    child: Stack(
                      children: [
                        // Falling items
                        ...items.map(
                          (item) => Positioned(
                            left:
                                (MediaQuery.of(context).size.width * 0.5) +
                                (item.x *
                                    MediaQuery.of(context).size.width *
                                    0.5) -
                                25,
                            top: item.y * MediaQuery.of(context).size.height,
                            child: Image.asset(
                              item.image,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),

                        // Basket
                        Positioned(
                          bottom: 50,
                          left:
                              (MediaQuery.of(context).size.width * 0.5) +
                              (basketX * MediaQuery.of(context).size.width) -
                              50,
                          child: Icon(
                            Icons.shopping_basket,
                            size: 100,
                            color: Colors.brown[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Text(
                  'اجمع الأكل الصحي وابعد عن الحلويات!',
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
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

  FallingItem({
    required this.x,
    required this.y,
    required this.isHealthy,
    required this.image,
  });
}
