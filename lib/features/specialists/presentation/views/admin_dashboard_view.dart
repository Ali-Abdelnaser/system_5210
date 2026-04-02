import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:five2ten/core/theme/app_theme.dart';
import 'package:five2ten/core/utils/app_images.dart';
import 'package:five2ten/core/widgets/app_back_button.dart';
import 'package:five2ten/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:five2ten/features/specialists/data/models/doctor_model.dart';
import 'package:five2ten/features/specialists/presentation/views/admin_edit_doctor_view.dart';
import 'package:five2ten/features/healthy_recipes/data/models/recipe_model.dart';
import 'package:five2ten/features/healthy_recipes/presentation/views/admin_edit_recipe_view.dart';
import 'package:five2ten/features/game_center/data/models/user_points_model.dart';
import 'package:five2ten/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:five2ten/core/widgets/profile_image_loader.dart';
import 'package:five2ten/core/utils/app_alerts.dart';
import 'package:five2ten/core/utils/app_strings.dart';
import 'package:five2ten/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:five2ten/features/healthy_insights/domain/entities/healthy_insight.dart';
import 'package:five2ten/features/healthy_insights/presentation/views/admin_edit_insight_view.dart';
import 'package:five2ten/core/widgets/app_shimmer.dart';
import 'package:five2ten/features/healthy_insights/data/models/healthy_insights_data.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    // Enable admin controls in the Cubit when this view is active
    context.read<UserPointsCubit>().setAdminAuthenticated(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textColor = const Color(0xFF1E293B);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            l10n.adminSystemDashboard,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const AppBackButton(),
          actions: [
            IconButton(
              onPressed: () => _showUpdateConfigDialog(l10n),
              icon: const Icon(
                Icons.system_update_rounded,
                color: AppTheme.appBlue,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.appRed),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.appBlue,
            labelColor: AppTheme.appBlue,
            unselectedLabelColor: Colors.grey,
            labelStyle: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: l10n.specialists),
              Tab(text: l10n.recipes),
              Tab(text: isAr ? 'المعلومات' : 'Insights'),
              Tab(text: isAr ? 'المستخدمين' : 'Users'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Expanded(child: _buildSpecialistsList(l10n, textColor)),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Expanded(child: _buildRecipesList(l10n, textColor)),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Expanded(child: _buildInsightsList(textColor, isAr)),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Expanded(child: _buildUsersList(textColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                final tabIndex = DefaultTabController.of(context).index;
                if (tabIndex == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEditDoctorView(),
                    ),
                  );
                } else if (tabIndex == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEditRecipeView(),
                    ),
                  );
                } else if (tabIndex == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEditInsightView(),
                    ),
                  );
                }
              },
              backgroundColor: AppTheme.appBlue,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                l10n.update, // generic "Add" or similar
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialistsList(AppLocalizations l10n, Color textColor) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() {});
      },
      color: AppTheme.appBlue,
      backgroundColor: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('specialists')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: textColor),
              ),
            );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) => AppShimmer.listTile(),
            );
          }

          final doctors = snapshot.data!.docs;

          if (doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 80,
                    color: textColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.adminNoDoctors,
                    style: GoogleFonts.cairo(color: textColor, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final data = doc.data() as Map<String, dynamic>;
              final doctor = DoctorModel.fromFirestore(data, doc.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.05,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(doctor.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.nameAr,
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              doctor.specialtyAr,
                              style: GoogleFonts.cairo(
                                color: textColor.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: AppTheme.appBlue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminEditDoctorView(doctor: doctor),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_rounded,
                            color: AppTheme.appRed,
                            onTap: () =>
                                _showDeleteDialog(l10n, 'specialists', doc.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecipesList(AppLocalizations l10n, Color textColor) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() {});
      },
      color: AppTheme.appBlue,
      backgroundColor: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('healthy_recipes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: textColor),
              ),
            );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) => AppShimmer.listTile(),
            );
          }

          final recipesDocs = snapshot.data!.docs;

          if (recipesDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 80,
                    color: textColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.adminNoRecipes,
                    style: GoogleFonts.cairo(color: textColor, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: recipesDocs.length,
            itemBuilder: (context, index) {
              final doc = recipesDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final recipe = RecipeModel.fromFirestore(data, doc.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.05,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(recipe.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.nameAr,
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${recipe.ingredientsAr.length} ${l10n.ingredients}',
                              style: GoogleFonts.cairo(
                                color: textColor.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: AppTheme.appBlue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminEditRecipeView(recipe: recipe),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_rounded,
                            color: AppTheme.appRed,
                            onTap: () => _showDeleteDialog(
                              l10n,
                              'healthy_recipes',
                              doc.id,
                              true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUsersList(Color textColor) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<UserPointsCubit>().fetchLeaderboard();
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('user_points')
            .orderBy('totalPoints', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) => AppShimmer.listTile(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final players = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final doc = players[index];
              final data = doc.data();
              final player = LeaderboardEntry(
                uid: doc.id,
                name: data['userName'] ?? 'لاعب',
                photoUrl: data['userPhoto'],
                points: data['totalPoints'] ?? 0,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.05,
                  color: Colors.white,
                  child: Row(
                    children: [
                      ProfileImageLoader(
                        photoUrl: player.photoUrl,
                        displayName: player.name,
                        size: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'النقاط: ${player.points}',
                              style: GoogleFonts.poppins(
                                color: textColor.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.refresh_rounded,
                            color: Colors.orange,
                            onTap: () => _showUserResetDialog(player),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: AppTheme.appRed,
                            onTap: () => _showUserWipeDialog(player),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInsightsList(Color textColor, bool isAr) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() {});
      },
      color: AppTheme.appBlue,
      backgroundColor: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('healthy_insights')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) => AppShimmer.listTile(),
            );
          }

          final insights = snapshot.data!.docs;

          if (insights.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 80,
                    color: textColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد معلومات صحية حالياً' : 'No insights found',
                    style: GoogleFonts.cairo(color: textColor, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _migrateInsights,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      isAr ? 'جلب المعلومات الأساسية' : 'Import Default Data',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.appBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final doc = insights[index];
              final data = doc.data() as Map<String, dynamic>;
              final insight = HealthyInsight.fromFirestore(data, doc.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.05,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.appBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: AppTheme.appBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.question,
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              insight.category,
                              style: GoogleFonts.cairo(
                                color: AppTheme.appBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: AppTheme.appBlue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminEditInsightView(insight: insight),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_rounded,
                            color: AppTheme.appRed,
                            onTap: () => _showDeleteDialog(
                              AppLocalizations.of(context)!,
                              'healthy_insights',
                              doc.id,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _migrateInsights() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection(
        'healthy_insights',
      );

      for (var insight in HealthyInsightsData.insights) {
        final docRef = collection.doc();
        batch.set(docRef, insight.toFirestore());
      }

      await batch.commit();

      if (mounted) {
        AppAlerts.showAlert(
          context,
          message:
              'تم استيراد ${HealthyInsightsData.insights.length} معلومة بنجاح',
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showAlert(context, message: 'خطأ: $e', type: AlertType.error);
      }
    }
  }

  void _showUserResetDialog(LeaderboardEntry player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 100),
        iconColor: AppTheme.appRed,
        iconPadding: const EdgeInsets.only(bottom: 8, top: 8),
        backgroundColor: Colors.white,
        title: const Text('تأكيد التصفير'),
        content: Text(
          'هل أنت متأكد من تصفير نقاط ${player.name}؟',
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.ltr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final result = await context
                  .read<UserPointsCubit>()
                  .adminResetUser(player.uid);
              if (ctx.mounted) Navigator.pop(ctx);

              if (result == null) {
                if (context.mounted) {
                  AppAlerts.showAlert(
                    context,
                    message: "تم تصفير النقاط بنجاح",
                    type: AlertType.success,
                  );
                }
              } else {
                if (context.mounted) {
                  AppAlerts.showAlert(
                    context,
                    message: "خطأ: $result",
                    type: AlertType.error,
                  );
                }
              }
            },
            child: const Text('تصفير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserWipeDialog(LeaderboardEntry player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 100),
        iconColor: AppTheme.appRed,
        iconPadding: const EdgeInsets.only(bottom: 8, top: 8),
        backgroundColor: Colors.white,
        title: const Text('مسح شامل'),
        titlePadding: const EdgeInsets.only(top: 8),

        content: Text('سيتم مسح كل تقدم ${player.name} في جميع الألعاب.!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.appRed),
            onPressed: () async {
              final result = await context
                  .read<UserPointsCubit>()
                  .adminWipeUserProgress(player.uid);
              if (ctx.mounted) Navigator.pop(ctx);

              if (result == null) {
                if (context.mounted) {
                  AppAlerts.showAlert(
                    context,
                    message: "تم مسح كل التقدم بنجاح",
                    type: AlertType.success,
                  );
                }
              } else {
                if (context.mounted) {
                  AppAlerts.showAlert(
                    context,
                    message: "خطأ: $result",
                    type: AlertType.error,
                  );
                }
              }
            },
            child: const Text('مسح كلي', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    AppLocalizations l10n,
    String collection,
    String docId, [
    bool isRecipe = false,
  ]) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.adminDeleteConfirmTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isRecipe
              ? l10n.adminDeleteRecipeConfirm
              : l10n.adminDeleteConfirmMessage,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection(collection)
                  .doc(docId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.appRed),
            child: Text(
              l10n.delete,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateConfigDialog(AppLocalizations l10n) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    // Fetch current settings first
    final doc = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('update_settings')
        .get();
    
    final data = doc.data() ?? {};
    final packageInfo = await PackageInfo.fromPlatform();
    
    final latestController = TextEditingController(text: data['latestVersion'] ?? packageInfo.version);
    final minController = TextEditingController(text: data['minRequiredVersion'] ?? packageInfo.version);
    final urlController = TextEditingController(text: data['updateUrl'] ?? AppStrings.storeUrl);

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: AppTheme.appBlue),
            const SizedBox(width: 12),
            Text(
              isAr ? 'إعدادات التحديثات' : 'Update Settings',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigField(
                label: isAr ? 'آخر إصدار (Latest)' : 'Latest Version',
                controller: latestController,
                hint: '1.0.0',
              ),
              const SizedBox(height: 16),
              _buildConfigField(
                label: isAr ? 'أدنى إصدار مطلوب (Min Required)' : 'Min Required Version',
                controller: minController,
                hint: '1.0.0',
              ),
              const SizedBox(height: 16),
              _buildConfigField(
                label: isAr ? 'رابط المتجر (Update URL)' : 'Update URL',
                controller: urlController,
                hint: 'https://...',
              ),
              const SizedBox(height: 12),
              Text(
                isAr 
                  ? 'إصدار التطبيق الحالي: ${packageInfo.version}'
                  : 'Current App Version: ${packageInfo.version}',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final latest = latestController.text.trim();
              final min = minController.text.trim();
              final url = urlController.text.trim();
              
              if (latest.isEmpty || min.isEmpty || url.isEmpty) {
                AppAlerts.showAlert(context, message: isAr ? "يرجى ملء جميع الحقول" : "Please fill all fields", type: AlertType.error);
                return;
              }

              Navigator.pop(context);
              await _updateConfig(latest, min, url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isAr ? 'حفظ الإعدادات' : 'Save Config',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _updateConfig(String latest, String min, String url) async {
    try {
      await FirebaseFirestore.instance
          .collection('app_config')
          .doc('update_settings')
          .set({
            'latestVersion': latest,
            'minRequiredVersion': min,
            'updateUrl': url,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        AppAlerts.showAlert(
          context,
          message: Localizations.localeOf(context).languageCode == 'ar'
              ? "تم حفظ إعدادات التحديث بنجاح"
              : "Update settings saved successfully",
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showAlert(
          context,
          message: "Error: $e",
          type: AlertType.error,
        );
      }
    }
  }
}
