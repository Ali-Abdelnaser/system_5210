import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:system_5210/features/profile/presentation/views/profile_view.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_intro_view.dart';
import 'package:system_5210/features/game_center/presentation/views/game_center_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        extendBody: true, // Important for floating nav bar
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeView(),
            ScanIntroView(),
            GameCenterView(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
