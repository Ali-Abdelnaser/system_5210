import 'package:flutter/material.dart';
import 'package:five2ten/core/services/notification_deep_link.dart';
import '../views/home_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:five2ten/features/profile/presentation/views/profile_view.dart';
import 'package:five2ten/features/nutrition_scan/presentation/pages/scan_intro_view.dart';
import 'package:five2ten/features/game_center/presentation/views/game_center_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationDeepLink.consumePendingIfAny();
    });
  }

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
        extendBody: true,
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
