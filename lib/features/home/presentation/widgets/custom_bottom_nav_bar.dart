import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      opacity: 0.2,
      blur: 25,
      borderRadius: 35,
      color: const Color(0xFFE3F2FD), // Subtle Blue Glass Tint
      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            AppImages.navHome,
            AppTheme.appBlue,
            l10n.navHome,
            isAr,
          ),
          _buildNavItem(
            1,
            AppImages.navScan,
            AppTheme.appYellow,
            l10n.navScan,
            isAr,
          ),
          _buildNavItem(
            2,
            AppImages.navGame,
            AppTheme.appRed,
            l10n.navGame,
            isAr,
          ),
          _buildNavItem(
            3,
            AppImages.navProfile,
            AppTheme.appGreen,
            l10n.navProfile,
            isAr,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String iconPath,
    Color activeColor,
    String label,
    bool isAr,
  ) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container with Glow
            SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? activeColor
                    : const Color.fromARGB(255, 63, 65, 66).withOpacity(0.45),
                BlendMode.srcIn,
              ),
              height: 24,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Text(
                  label,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: activeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
