import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:system_5210/features/specialists/domain/usecases/get_specialists.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:system_5210/features/specialists/presentation/views/doctor_details_view.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/specialists/presentation/views/admin_login_view.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/doctor_quick_card.dart';

class SpecialistsView extends StatefulWidget {
  const SpecialistsView({super.key});

  @override
  State<SpecialistsView> createState() => _SpecialistsViewState();
}

class _SpecialistsViewState extends State<SpecialistsView> {
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _titleTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialists() async {
    setState(() => isLoading = true);
    final result = await sl<GetSpecialists>().call();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (doctors) {
          setState(() {
            allDoctors = doctors;
            filteredDoctors = doctors;
            isLoading = false;
          });
        },
      );
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      final lang = Localizations.localeOf(context).languageCode;
      if (query.isEmpty) {
        filteredDoctors = allDoctors;
      } else {
        filteredDoctors = allDoctors
            .where(
              (doctor) =>
                  doctor
                      .getName(lang)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  doctor
                      .getSpecialty(lang)
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          RefreshIndicator(
            onRefresh: _loadSpecialists,
            color: AppTheme.appBlue,
            backgroundColor: Colors.white,
            edgeOffset: 140,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 140.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: const AppBackButton(),
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                      onTap: () {
                        _titleTapCount++;
                        if (_titleTapCount >= 4) {
                          _titleTapCount = 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLoginView(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      l10n.specialistsTitle,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),

                // Search Bar Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _buildSearchField(l10n, isAr),
                  ),
                ),

                // Content Section
                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => AppShimmer.specialistGridCard(),
                        childCount: 6,
                      ),
                    ),
                  )
                else if (filteredDoctors.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noSpecialistsFound,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doctor = filteredDoctors[index];
                        return DoctorQuickCard(
                              doctor: doctor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailsView(doctor: doctor),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              curve: Curves.easeOutBack,
                            );
                      }, childCount: filteredDoctors.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, bool isAr) {
    return GlassContainer(
      blur: 20,
      opacity: 0.8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        controller: _searchController,
        onChanged: _filterDoctors,
        decoration: InputDecoration(
          hintText: l10n.specialistsSearchHint,
          hintStyle: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.appBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }
}
