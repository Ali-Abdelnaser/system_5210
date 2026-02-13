import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import '../views/home_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:system_5210/features/profile/presentation/views/profile_view.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_intro_view.dart';
import '../manager/home_cubit.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<HomeCubit>()..loadUserProfile()),
        BlocProvider(create: (context) => sl<ProfileCubit>()..getProfile()),
      ],
      child: PopScope(
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
              Center(child: Text("Game Screen (Coming Soon)")),
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
      ),
    );
  }
}
