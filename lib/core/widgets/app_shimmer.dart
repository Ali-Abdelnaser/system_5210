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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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
}
