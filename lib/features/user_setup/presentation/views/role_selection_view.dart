import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../presentation/manager/user_setup_cubit.dart';

import 'package:flutter_svg/flutter_svg.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? const BackButton(color: Colors.black)
            : null,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height,
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // App Logo (Restored and Centered)
                  Center(
                    child: Image.asset(
                      AppImages.logo,
                      height: isSmallScreen ? 140 : 220,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    l10n.welcomeHero,
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.chooseRole,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 40),

                  // Roles using the premium white button style
                  _RoleButton(
                    title: l10n.roleParent,
                    subtitle: l10n.parentDesc,
                    iconPath: AppImages.iconParent,
                    onTap: () {
                      context.read<UserSetupCubit>().selectRole('parent');
                      Navigator.pushNamed(context, AppRoutes.parentQuiz);
                    },
                  ),
                  const SizedBox(height: 16),
                  _RoleButton(
                    title: l10n.roleChild,
                    subtitle: l10n.childDesc,
                    iconPath: AppImages.iconChild,
                    onTap: () {
                      context.read<UserSetupCubit>().selectRole('child');
                      Navigator.pushNamed(context, AppRoutes.childQuiz);
                    },
                  ),
                  const SizedBox(height: 250),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1565C0);
    const borderColor = Color(0xFFF1F5F9);

    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    iconPath,
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Text Area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFCBD5E1),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
