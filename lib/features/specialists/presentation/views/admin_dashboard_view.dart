import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/features/specialists/data/models/doctor_model.dart';
import 'package:system_5210/features/specialists/presentation/views/admin_edit_doctor_view.dart';
import 'package:system_5210/features/healthy_recipes/data/models/recipe_model.dart';
import 'package:system_5210/features/healthy_recipes/presentation/views/admin_edit_recipe_view.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textColor = const Color(0xFF1E293B);

    return DefaultTabController(
      length: 2,
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
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEditRecipeView(),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('specialists').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: textColor),
            ),
          );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator());
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
    );
  }

  Widget _buildRecipesList(AppLocalizations l10n, Color textColor) {
    return StreamBuilder<QuerySnapshot>(
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
          return const Center(child: AppLoadingIndicator());
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
}
