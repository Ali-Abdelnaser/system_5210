import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_images.dart';
import '../widgets/promo_slider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/mystery_mission_card.dart';
import '../widgets/daily_summary_card.dart';
import 'package:system_5210/features/daily_challenge/presentation/views/daily_challenge_view.dart';
import 'package:system_5210/features/specialists/presentation/views/specialists_view.dart';
import 'package:system_5210/features/specialists/presentation/widgets/doctor_quick_card.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:system_5210/features/specialists/presentation/views/doctor_details_view.dart';
import 'package:system_5210/features/healthy_recipes/presentation/widgets/recipes_section.dart';
import '../manager/home_cubit.dart';
import 'package:system_5210/features/healthy_insights/presentation/widgets/insight_promo_banner.dart';
import 'package:system_5210/features/healthy_recipes/presentation/manager/recipe_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/features/games/bonding_game/presentation/widgets/bonding_daily_card.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/features/notifications/presentation/manager/notification_cubit.dart';
import '../widgets/daily_tip_overlay.dart';
import 'package:system_5210/features/step_tracker/presentation/widgets/step_tracker_card.dart';
import 'package:system_5210/features/step_tracker/presentation/manager/step_tracker_cubit.dart';
import 'package:system_5210/features/step_tracker/presentation/views/activity_details_view.dart';
import 'package:system_5210/core/services/update_service.dart';
import 'package:system_5210/core/utils/injection_container.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for app updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<UpdateService>().checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-init StepTracker to check permissions again
      context.read<StepTrackerCubit>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // 1. App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // 2. Decorative elements to match internal pages
          // Positioned(
          //   top: -100,
          //   right: -100,
          //   child: CircleAvatar(
          //     radius: 200,
          //     backgroundColor: AppTheme.appBlue.withOpacity(0.03),
          //   ),
          // ),
          RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context
                    .read<HomeCubit>()
                    .loadUserProfile(), // Now loads specialists too
                context.read<RecipeCubit>().getRecipes(),
                context.read<ProfileCubit>().getProfile(),
              ]);
            },
            color: AppTheme.appBlue,
            child: BlocBuilder<BondingGameCubit, BondingGameState>(
              builder: (context, bondingState) {
                bool isLocked = false;
                if (bondingState is BondingGameReady) {
                  isLocked = bondingState.isScrollingLocked;
                }

                return CustomScrollView(
                  physics: isLocked
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // 1. App Bar
                    SliverToBoxAdapter(
                      child: BlocConsumer<HomeCubit, HomeState>(
                        listener: (context, state) {
                          if (state is HomeLoaded) {
                            DailyTipOverlay.showIfNeeded(
                              context,
                              state.userProfile.role,
                            );

                            context.read<NotificationCubit>().setUserContext(
                              state.userProfile.uid,
                              state.userProfile.createdAt,
                              role: state.userProfile.role,
                            );

                            if (state.streakResult != null) {
                              final status = state.streakResult!['status'];
                              final previousStreak =
                                  state.streakResult!['previousStreak'];

                              if (status == 'reset' && previousStreak > 0) {
                                AppAlerts.showCustomDialog(
                                  context,
                                  title: l10n.streakResetTitle,
                                  message: l10n.streakResetMessage(
                                    previousStreak,
                                  ),
                                  buttonText: l10n.streakContinue,
                                  isSuccess: false,
                                  icon: Icons.refresh_rounded,
                                  onPressed: () => Navigator.pop(context),
                                );
                              }
                            }

                            context
                                .read<NotificationCubit>()
                                .scheduleDailyTipsIfNeeded(
                                  state.userProfile.role,
                                );
                          }
                        },
                        builder: (context, state) {
                          String name = l10n.heroName;
                          int streakCount = 0;
                          String streakStatus = 'active';
                          if (state is HomeLoaded) {
                            name = state.displayName;
                            streakCount = state.userProfile.currentStreak;
                            streakStatus = state.userProfile.streakStatus;
                          }
                          return HomeAppBar(
                            displayName: name,
                            streakCount: streakCount,
                            streakStatus: streakStatus,
                            isLoading:
                                state is HomeInitial || state is HomeLoading,
                          );
                        },
                      ),
                    ),

                    // 2. Slider
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: PromoSlider(),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    ),

                    // 3. Activity Section (Glassified)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildSectionTitle(
                            title: isAr
                                ? 'نشاط البطل اليومي'
                                : 'Daily Hero Activity',
                            actionText: isAr ? 'التفاصيل' : 'Details',
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ActivityDetailsView(),
                                ),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 25),
                            child: StepTrackerCard(),
                          ),
                        ],
                      ),
                    ),

                    // 4. Bonding Game Section
                    SliverToBoxAdapter(
                      child: BlocBuilder<BondingGameCubit, BondingGameState>(
                        builder: (context, state) {
                          final isDone =
                              state is BondingGameReady &&
                              state.isMissionAccomplished;
                          return Column(
                            children: [
                              _buildSectionTitle(
                                title: isDone
                                    ? l10n.missionComplete
                                    : l10n.bondingHomeAnnouncement,
                                actionText: "",
                                onActionTap: () {},
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: const BondingDailyCard()
                                    .animate()
                                    .fadeIn(delay: 300.ms)
                                    .slideY(begin: 0.2),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // 5. Important Information (Insight Banner)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: InsightPromoBanner(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.healthyInsights,
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final isLoading =
                              state is HomeInitial || state is HomeLoading;
                          final specialists = (state is HomeLoaded)
                              ? state.specialists
                              : <Doctor>[];

                          return Column(
                            children: [
                              _buildSectionTitle(
                                title: l10n.specialistsTitle,
                                actionText: l10n.seeAll,
                                onActionTap: () =>
                                    _navigateToSpecialists(context),
                              ).animate().fadeIn(delay: 400.ms),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: SizedBox(
                                  height: 240,
                                  child: isLoading
                                      ? ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 4,
                                          itemBuilder: (context, index) =>
                                              AppShimmer.specialistCard(),
                                        )
                                      : specialists.isEmpty
                                      ? Center(child: Text(l10n.noSpecialists))
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: specialists.length > 5
                                              ? 6
                                              : specialists.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index ==
                                                (specialists.length > 5
                                                    ? 5
                                                    : specialists.length)) {
                                              return _buildSeeAllCard(
                                                context,
                                                l10n,
                                                isAr,
                                              );
                                            }
                                            return DoctorQuickCard(
                                              doctor: specialists[index],
                                              onTap: () =>
                                                  _navigateToDoctorDetails(
                                                    context,
                                                    specialists[index],
                                                  ),
                                            );
                                          },
                                        ),
                                ),
                              ).animate().fadeIn(delay: 450.ms),
                            ],
                          );
                        },
                      ),
                    ),

                    // 7. Healthy Recipes
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: RecipesSection(),
                      ),
                    ),

                    // // 8. The Rest (Daily Target, Mystery Mission)
                    // SliverToBoxAdapter(
                    //   child: _buildSectionTitle(
                    //     title: l10n.dailyTarget,
                    //     actionText: l10n.seeAll,
                    //     onActionTap: () => _navigateToDailyChallenge(context),
                    //   ),
                    // ),
                    // SliverToBoxAdapter(
                    //   child: DailySummaryCard(
                    //     completedTargets: 1,
                    //     totalTargets: 4,
                    //     onTap: () => _navigateToDailyChallenge(context),
                    //   ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                    // ),
                    // const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    // SliverToBoxAdapter(
                    //   child: MysteryMissionCard(
                    //     onTap: () => _showSurpriseMissionDialog(context, l10n),
                    //   ),
                    // ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                (Localizations.localeOf(context).languageCode == 'ar'
                ? GoogleFonts.cairo
                : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
          ),
          if (actionText.isNotEmpty)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText,
                style:
                    (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.appBlue,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToDailyChallenge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyChallengeView()),
    );
  }

  void _showSurpriseMissionDialog(BuildContext context, AppLocalizations l10n) {
    final List<Map<String, dynamic>> missions = [
      {
        "icon": Icons.water_drop,
        "title": l10n.missionHydrationTitle,
        "text": l10n.missionHydrationText,
      },
      {
        "icon": Icons.directions_run,
        "title": l10n.missionEnergyTitle,
        "text": l10n.missionEnergyText,
      },
      {
        "icon": Icons.apple,
        "title": l10n.missionSnackTitle,
        "text": l10n.missionSnackText,
      },
      {
        "icon": Icons.favorite,
        "title": l10n.missionLoveTitle,
        "text": l10n.missionLoveText,
      },
    ];

    final mission = (missions..shuffle()).first;

    AppAlerts.showCustomDialog(
      context,
      title: mission['title'],
      message: mission['text'],
      buttonText: l10n.missionComplete,
      isSuccess: true,
      icon: mission['icon'],
      iconColor: const Color(0xFF8B5CF6),
      buttonColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      onPressed: () => Navigator.pop(context),
    );
  }

  void _navigateToDoctorDetails(BuildContext context, Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsView(doctor: doctor),
      ),
    );
  }

  void _navigateToSpecialists(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SpecialistsView()),
    );
  }

  Widget _buildSeeAllCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return GestureDetector(
      onTap: () => _navigateToSpecialists(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.appBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: AppTheme.appBlue,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.seeAll,
              style:
                  (Localizations.localeOf(context).languageCode == 'ar'
                  ? GoogleFonts.cairo
                  : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.appBlue,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
