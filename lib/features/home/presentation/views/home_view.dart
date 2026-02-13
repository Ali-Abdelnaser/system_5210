import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/promo_slider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/mystery_mission_card.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/fun_zone_activity_card.dart';
import 'package:system_5210/features/daily_challenge/presentation/views/daily_challenge_view.dart';
import 'package:system_5210/features/specialists/presentation/views/specialists_view.dart';
import 'package:system_5210/features/specialists/presentation/widgets/doctor_quick_card.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/features/specialists/domain/usecases/get_specialists.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:system_5210/features/specialists/presentation/views/doctor_details_view.dart';
import 'package:system_5210/features/healthy_recipes/presentation/widgets/recipes_section.dart';
import '../manager/home_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Doctor> specialists = [];
  bool isLoadingSpecialists = true;

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  Future<void> _loadSpecialists() async {
    setState(() => isLoadingSpecialists = true);
    final result = await sl<GetSpecialists>().call();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            isLoadingSpecialists = false;
          });
        },
        (data) {
          setState(() {
            specialists = data;
            isLoadingSpecialists = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSpecialists();
          context.read<HomeCubit>().loadUserProfile();
        },
        color: AppTheme.appBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  String name = l10n.heroName;
                  if (state is HomeLoaded) {
                    name = state.displayName;
                  }
                  return HomeAppBar(
                    displayName: name,
                    streakCount: 3,
                    isLoading: state is HomeInitial || state is HomeLoading,
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: PromoSlider(),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                title: l10n.specialistsTitle,
                actionText: l10n.seeAll,
                onActionTap: () => _navigateToSpecialists(context),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: isLoadingSpecialists
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) =>
                            AppShimmer.specialistCard(),
                      )
                    : specialists.isEmpty
                    ? Center(child: Text(l10n.noSpecialists))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: specialists.length > 5
                            ? 6
                            : specialists.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              (specialists.length > 5
                                  ? 5
                                  : specialists.length)) {
                            return _buildSeeAllCard(context, l10n);
                          }
                          return DoctorQuickCard(
                            doctor: specialists[index],
                            onTap: () => _navigateToDoctorDetails(
                              context,
                              specialists[index],
                            ),
                          );
                        },
                      ),
              ),
            ),
            SliverToBoxAdapter(child: const RecipesSection()),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                title: l10n.dailyTarget,
                actionText: l10n.seeAll,
                onActionTap: () => _navigateToDailyChallenge(context),
              ),
            ),
            SliverToBoxAdapter(
              child: DailySummaryCard(
                completedTargets: 1,
                totalTargets: 4,
                onTap: () => _navigateToDailyChallenge(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: MysteryMissionCard(
                onTap: () => _showSurpriseMissionDialog(context, l10n),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 15),
                child: Text(
                  l10n.funZone,
                  style:
                      (Localizations.localeOf(context).languageCode == 'ar'
                      ? GoogleFonts.cairo
                      : GoogleFonts.poppins)(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  children: [
                    FunZoneActivityCard(
                      title: l10n.quiz,
                      icon: Icons.lightbulb_rounded,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                    FunZoneActivityCard(
                      title: l10n.videos,
                      icon: Icons.play_circle_fill,
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    FunZoneActivityCard(
                      title: l10n.badges,
                      icon: Icons.emoji_events_rounded,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                (Localizations.localeOf(context).languageCode == 'ar'
                ? GoogleFonts.cairo
                : GoogleFonts.poppins)(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3142),
                ),
          ),
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
      buttonText: l10n.missionComplete, // e.g. "Awesome!"
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

  Widget _buildSeeAllCard(BuildContext context, AppLocalizations l10n) {
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
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.appBlue,
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
