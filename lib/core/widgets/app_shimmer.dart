import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Widget listTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          AppShimmer(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 150, height: 14),
                const SizedBox(height: 8),
                AppShimmer(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget specialistCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 20, bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppShimmer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppShimmer(width: 80, height: 14),
                  const SizedBox(height: 6),
                  AppShimmer(
                    width: 60,
                    height: 18,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static Widget recipeCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(
            width: double.infinity,
            height: 140,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 120, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget specialistGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppShimmer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppShimmer(width: 80, height: 14),
                  const SizedBox(height: 6),
                  AppShimmer(
                    width: 60,
                    height: 18,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static Widget recipeGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(
            width: double.infinity,
            height: 140,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 120, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget notificationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer(
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(25),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(width: 150, height: 16),
                  const SizedBox(height: 10),
                  AppShimmer(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  AppShimmer(width: 200, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget taskGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppShimmer(
            width: 70,
            height: 70,
            borderRadius: BorderRadius.circular(35),
          ),
          const SizedBox(height: 16),
          AppShimmer(width: 100, height: 16),
        ],
      ),
    );
  }

  static Widget insightCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
              AppShimmer(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppShimmer(
            width: 4,
            height: 24,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          AppShimmer(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          AppShimmer(width: 200, height: 20),
        ],
      ),
    );
  }

  static Widget profileShimmer() {
    return Column(
      children: [
        const SizedBox(height: 80),
        AppShimmer(
          width: 170,
          height: 170,
          borderRadius: BorderRadius.circular(85),
        ),
        const SizedBox(height: 24),
        AppShimmer(width: 200, height: 32),
        const SizedBox(height: 10),
        AppShimmer(
          width: 100,
          height: 28,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              AppShimmer(
                width: double.infinity,
                height: 180,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(height: 32),
              AppShimmer(
                width: double.infinity,
                height: 180,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(height: 32),
              AppShimmer(
                width: double.infinity,
                height: 180,
                borderRadius: BorderRadius.circular(24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget gameCenterShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppShimmer(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppShimmer(
                width: 85,
                height: 180,
                borderRadius: BorderRadius.circular(25),
              ),
              AppShimmer(
                width: 100,
                height: 220,
                borderRadius: BorderRadius.circular(25),
              ),
              AppShimmer(
                width: 85,
                height: 160,
                borderRadius: BorderRadius.circular(25),
              ),
            ],
          ),
          const SizedBox(height: 30),
          AppShimmer(
            width: double.infinity,
            height: 60,
            borderRadius: BorderRadius.circular(24),
          ),
        ],
      ),
    );
  }

  static Widget recentScanCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          AppShimmer(
            width: 65,
            height: 65,
            borderRadius: BorderRadius.circular(33),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppShimmer(width: 80, height: 12),
                    const Spacer(),
                    AppShimmer(
                      width: 60,
                      height: 18,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppShimmer(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 150, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget promoSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppShimmer(
        width: double.infinity,
        height: 160,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static Widget activityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppShimmer(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static Widget bondingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppShimmer(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static Widget insightBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppShimmer(
        width: double.infinity,
        height: 100,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
