import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import '../../domain/entities/healthy_insight.dart';
import '../widgets/insight_card.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';

class HealthyInsightsView extends StatefulWidget {
  const HealthyInsightsView({super.key});

  @override
  State<HealthyInsightsView> createState() => _HealthyInsightsViewState();
}

class _HealthyInsightsViewState extends State<HealthyInsightsView> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'الكل',
    'السمنة',
    'التغذية',
    'الصحة الرقمية',
    'النشاط البدني',
    'الصحة العامة',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
          ),

          RefreshIndicator(
            onRefresh: () async {
              // Since it's a stream, it updates automatically,
              // but we can add a small delay for UX or re-trigger any logic if needed.
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) setState(() {});
            },
            color: AppTheme.appBlue,
            backgroundColor: Colors.white,
            edgeOffset: 200, // Start below the app bar
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ... rest of slivers ...
                // Modern Animated AppBar
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const AppBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.appBlue,
                                AppTheme.appBlue.withOpacity(0.8),
                                const Color(0xFF6366F1),
                              ],
                            ),
                          ),
                        ),
                        // Decorative Elements
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lightbulb_rounded,
                                size: 48,
                                color: Colors.white,
                              ).animate().scale(
                                delay: 200.ms,
                                curve: Curves.easeOutBack,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'معلومات تهمك',
                                style: GoogleFonts.cairo(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'دليلك لصحة طفلك وعائلتك',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search and Filter Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن معلومة...',
                              hintStyle: GoogleFonts.cairo(
                                color: Colors.grey[400],
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.appBlue,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                        const SizedBox(height: 20),

                        // Categories Chips
                        SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(
                                      () => _selectedCategory = category,
                                    );
                                  },
                                  labelStyle: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blueGrey[700],
                                  ),
                                  selectedColor: AppTheme.appBlue,
                                  backgroundColor: Colors.white,
                                  checkmarkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppTheme.appBlue
                                          : Colors.grey[200]!,
                                    ),
                                  ),
                                  elevation: isSelected ? 4 : 0,
                                  pressElevation: 2,
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),
                ),

                // Insights List
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('healthy_insights')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SliverFillRemaining(
                        child: Center(child: Text('حدث خطأ في جلب البيانات')),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => AppShimmer.insightCard(),
                            childCount: 5,
                          ),
                        ),
                      );
                    }

                    final allInsights = snapshot.data!.docs.map((doc) {
                      return HealthyInsight.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      );
                    }).toList();

                    final filteredInsights = allInsights.where((insight) {
                      final matchesSearch =
                          insight.question.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          insight.answer.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                      final matchesCategory =
                          _selectedCategory == 'الكل' ||
                          insight.category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (filteredInsights.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد نتائج بحث',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return InsightCard(
                                insight: filteredInsights[index],
                                index: index,
                              )
                              .animate()
                              .fadeIn(delay: (index * 100).ms)
                              .slideY(begin: 0.1);
                        }, childCount: filteredInsights.length),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
