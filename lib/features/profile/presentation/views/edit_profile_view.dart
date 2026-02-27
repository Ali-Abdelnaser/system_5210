import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_5210/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'dart:ui';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/utils/app_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:system_5210/core/widgets/profile_image_loader.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  String? _selectedRelationship;
  String? _selectedPriority;
  bool _isPriorityExpanded = false;
  bool _isRelationshipExpanded = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      final profile = profileState.profile;
      _nameController = TextEditingController(text: profile.displayName);
      _cityController = TextEditingController(
        text: profile.parentProfile?['city'] ?? '',
      );

      final savedRelationship = profile.parentProfile?['relationship'];
      const validRelationships = ['Mother', 'Father', 'Guardian'];
      if (validRelationships.contains(savedRelationship)) {
        _selectedRelationship = savedRelationship;
      } else {
        _selectedRelationship = 'Mother';
      }

      _selectedPriority = profile.parentProfile?['priority'];
    } else {
      _nameController = TextEditingController();
      _cityController = TextEditingController();
      _selectedRelationship = 'Mother';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.editProfile,
          style: GoogleFonts.dynaPuff(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: BlocListener<UserSetupCubit, UserSetupState>(
        listener: (context, state) {
          if (state is UserSetupSuccess) {
            context.read<ProfileCubit>().getProfile();
            _showSuccessDialog(context, l10n);
          } else if (state is UserSetupFailure) {
            AppAlerts.showAlert(
              context,
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileImage(context, l10n),
                      const SizedBox(height: 24),
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          final profile = (state is ProfileLoaded)
                              ? state.profile
                              : null;
                          return _buildGlassForm(context, l10n, profile);
                        },
                      ),
                      const SizedBox(height: 80),
                      BlocBuilder<UserSetupCubit, UserSetupState>(
                        builder: (context, state) {
                          return AuthGradientButton(
                            text: l10n.save,
                            onTap: _save,
                            colors: const [
                              Color(0xFF1565C0),
                              Color(0xFF0D47A1),
                            ],
                            isLoading: state is UserSetupLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassForm(
    BuildContext context,
    AppLocalizations l10n,
    dynamic profile, // Using dynamic to avoid circular import issues for now
  ) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUpdateSuccess) {
          Navigator.pop(context); // Close dialog if open
          AppAlerts.showCustomDialog(
            context,
            title: l10n.success,
            message: state.message,
            buttonText: l10n.ok,
            isSuccess: true,
            onPressed: () => Navigator.pop(context),
          );
        } else if (state is AuthFailure) {
          Navigator.pop(context); // Close loading dialog if open
          AppAlerts.showAlert(
            context,
            message: state.message,
            type: AlertType.error,
          );
        } else if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: AppLoadingIndicator(size: 80)),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(l10n.personalInfo),
                const SizedBox(height: 20),
                _buildModernTextField(
                  controller: _nameController,
                  label: l10n.fullName,
                  iconPath: AppImages.iconUser,
                  validator: (value) =>
                      AppValidators.validateName(value, context),
                ),
                if (profile?.role != 'child') ...[
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _cityController,
                    label: l10n.city,
                    iconPath: AppImages.iconLocation,
                    validator: (value) {
                      if (profile?.role == 'child') return null;
                      return AppValidators.validateRequired(value, context);
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(l10n.generalPreferences),
                  const SizedBox(height: 20),
                  _buildModernLabel(l10n.relationship),
                  const SizedBox(height: 10),
                  _buildChicGlassDropdown(
                    label: l10n.selectField(l10n.relationship),
                    value: _selectedRelationship,
                    items: [
                      {'val': 'Mother', 'label': l10n.mother},
                      {'val': 'Father', 'label': l10n.father},
                      {'val': 'Guardian', 'label': l10n.guardian},
                    ],
                    onSelect: (v) => setState(() {
                      _selectedRelationship = v;
                      _isRelationshipExpanded = false;
                    }),
                    iconPath: AppImages.iconUser,
                    isExpanded: _isRelationshipExpanded,
                    onToggle: () => setState(() {
                      _isRelationshipExpanded = !_isRelationshipExpanded;
                      _isPriorityExpanded = false;
                    }),
                  ),
                  const SizedBox(height: 24),
                  _buildModernLabel(l10n.familyPriority),
                  const SizedBox(height: 10),
                  _buildChicGlassDropdown(
                    label: "Select Priority",
                    value: _selectedPriority,
                    items: [
                      {
                        'val': "Healthy Eating",
                        'label': l10n.healthPriorityHealthyEating,
                      },
                      {
                        'val': "Physical Activity",
                        'label': l10n.healthPriorityPhysicalActivity,
                      },
                      {
                        'val': "Reduced Screen Time",
                        'label': l10n.healthPriorityReducedScreenTime,
                      },
                      {
                        'val': "Zero Soda",
                        'label': l10n.healthPriorityZeroSoda,
                      },
                    ],
                    onSelect: (v) => setState(() {
                      _selectedPriority = v;
                      _isPriorityExpanded = false;
                    }),
                    iconPath: AppImages.iconFamily,
                    isExpanded: _isPriorityExpanded,
                    onToggle: () => setState(() {
                      _isPriorityExpanded = !_isPriorityExpanded;
                      _isRelationshipExpanded = false;
                    }),
                  ),
                ],
                const SizedBox(height: 32),
                _buildSectionTitle(l10n.security),
                const SizedBox(height: 20),
                _buildSecurityOption(
                  context,
                  title: l10n.password,
                  subtitle: "••••••••",
                  icon: Icons.lock_outline_rounded,
                  onTap: () => _showChangePasswordDialog(context),
                  actionText: l10n.change,
                ),
                const SizedBox(height: 16),
                _buildSecurityOption(
                  context,
                  title: l10n.email,
                  subtitle: profile?.email ?? l10n.noEmail,
                  icon: Icons.alternate_email_rounded,
                  onTap: () => _showChangeEmailDialog(context),
                  actionText: l10n.change,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOption(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? actionText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (actionText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actionText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.changePassword,
          style: GoogleFonts.dynaPuff(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleTextField(
                controller: currentPassController,
                label: l10n.currentPassword,
                isPassword: true,
                validator: (v) => AppValidators.validatePassword(v, context),
              ),
              const SizedBox(height: 16),
              _buildSimpleTextField(
                controller: newPassController,
                label: l10n.newPassword,
                isPassword: true,
                validator: (v) => AppValidators.validatePassword(v, context),
              ),
              const SizedBox(height: 16),
              _buildSimpleTextField(
                controller: confirmPassController,
                label: l10n.confirmNewPassword,
                isPassword: true,
                validator: (v) {
                  if (v != newPassController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AuthCubit>().updatePasswordSettings(
                  currentPassword: currentPassController.text,
                  newPassword: newPassController.text,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.update,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPassController = TextEditingController();
    final newEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.changeEmail,
          style: GoogleFonts.dynaPuff(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.verifyNewEmailDesc,
                style: (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildSimpleTextField(
                controller: currentPassController,
                label: l10n.currentPassword,
                isPassword: true,
                validator: (v) => AppValidators.validatePassword(v, context),
              ),
              const SizedBox(height: 16),
              _buildSimpleTextField(
                controller: newEmailController,
                label: l10n.newEmail,
                validator: (v) => AppValidators.validateEmail(v, context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AuthCubit>().updateEmailSettings(
                  currentPassword: currentPassController.text,
                  newEmail: newEmailController.text,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.update,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style:
          (Localizations.localeOf(context).languageCode == 'ar'
          ? GoogleFonts.cairo
          : GoogleFonts.dynaPuff)(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
    );
  }

  Widget _buildModernLabel(String text) {
    return Text(
      text,
      style:
          (Localizations.localeOf(context).languageCode == 'ar'
          ? GoogleFonts.cairo
          : GoogleFonts.poppins)(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: (Localizations.localeOf(context).languageCode == 'ar'
              ? GoogleFonts.cairo
              : GoogleFonts
                    .poppins)(color: const Color(0xFF64748B), fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              iconPath,
              width: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1565C0),
                BlendMode.srcIn,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChicGlassDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String) onSelect,
    required String iconPath,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFF1565C0).withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1565C0),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style:
                            (Localizations.localeOf(context).languageCode ==
                                'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts.poppins)(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                      ),
                      Text(
                        value ?? l10n.chooseOne,
                        style:
                            (Localizations.localeOf(context).languageCode ==
                                'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts.poppins)(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: value == null
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF1E293B),
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: items.map((item) {
                    final isSelected = value == item['val'];
                    return InkWell(
                      onTap: () => onSelect(item['val']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0).withOpacity(0.1)
                              : Colors.transparent,
                          border: items.last == item
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label']!,
                              style:
                                  (Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar'
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF1565C0)
                                        : const Color(0xFF1E293B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded ||
            state is ProfileUploading ||
            state is ProfileUploadSuccess) {
          final profile = (state is ProfileLoaded)
              ? state.profile
              : (state is ProfileUploading)
              ? state.profile
              : (state as ProfileUploadSuccess).profile;
          return Center(
            child: Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.appBlue.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        ProfileImageLoader(
                          photoUrl: profile.photoUrl,
                          displayName: profile.displayName,
                          size: 130,
                          loadingSize: 40,
                          textSize: 50,
                        ),
                        _buildImageOverlay(context, state),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(context, l10n),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.appBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  static final ImagePicker _picker = ImagePicker();

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

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    AppAlerts.showCustomDialog(
      context,
      title: l10n.success,
      message: l10n.profileUpdated,
      buttonText: l10n.ok,
      isSuccess: true,
      onPressed: () {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Go back
      },
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final profileState = context.read<ProfileCubit>().state;
      if (profileState is ProfileLoaded) {
        final profile = profileState.profile;
        final updatedParentInfo = Map<String, dynamic>.from(
          profile.parentProfile ?? {},
        );

        final String newName = _nameController.text;

        if (profile.role == 'parent') {
          updatedParentInfo['fullName'] = newName;
          updatedParentInfo['city'] = _cityController.text;
          updatedParentInfo['relationship'] = _selectedRelationship;
          updatedParentInfo['priority'] = _selectedPriority;
        }

        context.read<UserSetupCubit>().updateUserProfile(
          uid: profile.uid,
          role: profile.role,
          parentProfileData: updatedParentInfo,
          quizAnswers: profile.quizAnswers,
          photoUrl: profile.photoUrl,
          displayName: newName,
          email: profile.email,
          phoneNumber: profile.phoneNumber,
        );
      }
    }
  }

  Widget _buildImageOverlay(BuildContext context, ProfileState state) {
    if (state is ProfileUploading) {
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircularProgressIndicator(
            value: state.progress,
            color: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showImageSourceDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF1565C0),
              ),
              title: Text(
                l10n.camera,
                style:
                    (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            Divider(color: Colors.grey.withOpacity(0.2)),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF1565C0),
              ),
              title: Text(
                l10n.gallery,
                style:
                    (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
