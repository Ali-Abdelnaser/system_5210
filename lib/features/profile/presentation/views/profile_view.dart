import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';
import 'package:system_5210/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'edit_profile_view.dart';
import 'edit_children_view.dart';
import 'privacy_policy_view.dart';
import 'support_view.dart';
import 'about_app_view.dart';
import '../widgets/profile_shimmer.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:system_5210/core/widgets/profile_image_loader.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const ProfileShimmer();
              }

              if (state is ProfileFailure) {
                return Center(child: Text(state.message));
              }

              if (state is ProfileLoaded ||
                  state is ProfileUploading ||
                  state is ProfileUploadSuccess) {
                final profile = (state is ProfileLoaded)
                    ? state.profile
                    : (state is ProfileUploading)
                    ? state.profile
                    : (state as ProfileUploadSuccess).profile;
                final isParent = profile.role == 'parent';

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ProfileCubit>().getProfile();
                  },
                  color: AppTheme.appBlue,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.only(top: 80, bottom: 40),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.appBlue.withOpacity(
                                            0.1,
                                          ),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Stack(
                                        children: [
                                          ProfileImageLoader(
                                            photoUrl: profile.photoUrl,
                                            displayName: profile.displayName,
                                            size: 160,
                                            loadingSize: 40,
                                            textSize: 60,
                                          ),
                                          _buildImageOverlay(context, state),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showImageSourceDialog(context, l10n),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.appBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.appBlue
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                profile.displayName ?? l10n.heroName,
                                style: GoogleFonts.cairo(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isParent
                                      ? AppTheme.appBlue.withOpacity(0.12)
                                      : AppTheme.appYellow.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isParent ? l10n.roleParent : l10n.roleChild,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isParent
                                        ? AppTheme.appBlue
                                        : AppTheme.appYellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildMenuCard(context, [
                              _ProfileMenuItem(
                                iconPath: AppImages.iconUser,
                                title: l10n.editProfile,
                                iconColor: AppTheme.appBlue,
                                onTap: () {
                                  final profileCubit = context
                                      .read<ProfileCubit>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: profileCubit,
                                        child: const EditProfileView(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (isParent)
                                _ProfileMenuItem(
                                  iconPath: AppImages.iconChild,
                                  title: l10n.editChildren,
                                  iconColor: AppTheme.appYellow,
                                  onTap: () {
                                    final profileCubit = context
                                        .read<ProfileCubit>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider.value(
                                              value: profileCubit,
                                              child: const EditChildrenView(),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                            ]),
                            const SizedBox(height: 32),
                            _buildSectionTitle(l10n.accountSettings),
                            const SizedBox(height: 12),

                            _buildMenuCard(context, [
                              _ProfileMenuItem(
                                icon: Icons.language_rounded,
                                title: l10n.language,
                                iconColor: const Color(0xFF64748B),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.language,
                                    arguments: true,
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF1F5F9),
                              ),
                              _ProfileMenuItem(
                                icon: Icons.notifications_active_outlined,
                                title: l10n.notifications,
                                iconColor: AppTheme.appBlue,
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF1F5F9),
                              ),
                              _ProfileMenuItem(
                                icon: Icons.security_rounded,
                                title: l10n.privacyPolicy,
                                iconColor: const Color(0xFF10B981),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyPolicyView(),
                                    ),
                                  );
                                },
                              ),
                            ]),

                            const SizedBox(height: 32),
                            _buildSectionTitle(l10n.support),
                            const SizedBox(height: 12),

                            _buildMenuCard(context, [
                              _ProfileMenuItem(
                                icon: Icons.help_outline_rounded,
                                title: l10n.support,
                                iconColor: AppTheme.appGreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SupportView(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF1F5F9),
                              ),
                              _ProfileMenuItem(
                                icon: Icons.info_outline_rounded,
                                title: l10n.aboutApp,
                                iconColor: AppTheme.appYellow,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AboutAppView(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF1F5F9),
                              ),
                              _ProfileMenuItem(
                                icon: Icons.star_border_rounded,
                                title: l10n.rateFeedback,
                                iconColor: AppTheme.appBlue,
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 70,
                                color: Color(0xFFF1F5F9),
                              ),
                              _ProfileMenuItem(
                                icon: Icons.lightbulb_outline_rounded,
                                title: l10n.healthyInsightsTitle,
                                iconColor: AppTheme.appYellow,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.healthyInsights,
                                  );
                                },
                              ),
                            ]),
                            const SizedBox(height: 32),
                            _buildMenuCard(context, [
                              _ProfileMenuItem(
                                icon: Icons.logout_rounded,
                                title: l10n.logout,
                                iconColor: AppTheme.appRed,
                                isDestructive: true,
                                onTap: () => _showLogoutConfirm(context, l10n),
                              ),
                            ]),
                            const SizedBox(height: 120),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ),
    );
  }

  static final ImagePicker _picker = ImagePicker();

  Widget _buildImageOverlay(BuildContext context, ProfileState state) {
    if (state is ProfileUploading) {
      return ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(state.progress * 100).toInt()}%",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state is ProfileUploadSuccess) {
      return ClipOval(
        child: Container(
          color: AppTheme.appGreen.withOpacity(0.7),
          child:
              const Center(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
              ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null) {
        if (context.mounted) {
          context.read<ProfileCubit>().uploadProfileImage(
            File(pickedFile.path),
          );
        }
      }
    } catch (e) {
      debugPrint("IMAGE PICKER ERROR: $e");
      if (context.mounted) {
        AppAlerts.showAlert(
          context,
          message: "Could not open ${source.name}: $e",
          type: AlertType.error,
        );
      }
    }
  }

  void _showImageSourceDialog(BuildContext context, AppLocalizations l10n) {
    AppAlerts.showAppDialog(
      context,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chooseImageSource,
                  style: GoogleFonts.dynaPuff(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOption(
                      icon: Icons.camera_alt_rounded,
                      label: l10n.camera,
                      color: AppTheme.appBlue,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.camera);
                      },
                    ),
                    _buildOption(
                      icon: Icons.photo_library_rounded,
                      label: l10n.gallery,
                      color: AppTheme.appGreen,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AppLocalizations l10n) {
    AppAlerts.showCustomDialog(
      context,
      title: l10n.logout,
      message: l10n.logoutConfirm,
      buttonText: l10n.logout,
      isSuccess: false,
      cancelText: l10n.cancel,
      icon: Icons.logout_rounded,
      onPressed: () {
        Navigator.pop(context);
        // Reset states to prevent data leak
        context.read<UserSetupCubit>().reset();
        try {
          context.read<ProfileCubit>().reset();
        } catch (e) {
          debugPrint("ProfileCubit not found to reset: $e");
        }

        context.read<AuthCubit>().logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final bool isDestructive;

  const _ProfileMenuItem({
    this.icon,
    this.iconPath,
    required this.title,
    required this.onTap,
    required this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive
        ? AppTheme.appRed
        : const Color(0xFF1E293B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: iconPath != null
                    ? SvgPicture.asset(
                        iconPath!,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                        width: 22,
                      )
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style:
                      (Localizations.localeOf(context).languageCode == 'ar'
                      ? GoogleFonts.cairo
                      : GoogleFonts.poppins)(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                ),
              ),
              if (!isDestructive)
                Icon(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: const Color(0xFFCBD5E1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
