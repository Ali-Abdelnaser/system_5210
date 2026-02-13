import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class RecipeDetailsView extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsView({super.key, required this.recipe});

  @override
  State<RecipeDetailsView> createState() => _RecipeDetailsViewState();
}

class _RecipeDetailsViewState extends State<RecipeDetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final name = widget.recipe.getName(languageCode);
    final ingredients = widget.recipe.getIngredients(languageCode);
    final steps = widget.recipe.getSteps(languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: AppBackButton(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe_${widget.recipe.id}',
                    child: Image.network(
                      widget.recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.appBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: AppTheme.appBlue,
                        ),
                      ),
                    ),
                  ),
                  // Darken top for status bar visibility and back button
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style:
                                  (languageCode == 'ar'
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3142),
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF4CAF50),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  languageCode == 'ar' ? 'صحي' : 'Healthy',
                                  style:
                                      (languageCode == 'ar'
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quick Info (Derived from data)
                      Row(
                        children: [
                          _buildQuickInfo(
                            icon: Icons.restaurant_menu_rounded,
                            label: languageCode == 'ar'
                                ? '${ingredients.length} مكونات'
                                : '${ingredients.length} Ingredients',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          _buildQuickInfo(
                            icon: Icons.format_list_numbered_rtl_rounded,
                            label: languageCode == 'ar'
                                ? '${steps.length} خطوات'
                                : '${steps.length} Steps',
                            color: AppTheme.appBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Ingredients Section
                      _buildSectionTitle(
                        l10n.ingredients,
                        Icons.shopping_bag_outlined,
                        languageCode,
                      ),
                      const SizedBox(height: 16),
                      ...ingredients.map(
                        (item) => _buildItemList(
                          item,
                          languageCode,
                          Icons.check_circle_outline,
                          Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Preparation Section
                      _buildSectionTitle(
                        languageCode == 'ar' ? 'طريقة التحضير' : 'Preparation',
                        Icons.auto_awesome_outlined,
                        languageCode,
                      ),
                      const SizedBox(height: 16),
                      ...steps.asMap().entries.map(
                        (entry) => _buildStepItem(
                          entry.key + 1,
                          entry.value,
                          languageCode,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Video Button
                      if (widget.recipe.videoUrl.isNotEmpty)
                        _buildVideoButton(l10n, languageCode),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, String lang) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D3142), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: (lang == 'ar' ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList(String text, String lang, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: (lang == 'ar' ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 15,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int number, String text, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.appBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: (lang == 'ar' ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 15,
                color: const Color(0xFF2D3142),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoButton(AppLocalizations l10n, String languageCode) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.appBlue, Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.appBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(widget.recipe.videoUrl),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
        label: Text(
          l10n.watchVideo,
          style:
              (languageCode == 'ar' ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
