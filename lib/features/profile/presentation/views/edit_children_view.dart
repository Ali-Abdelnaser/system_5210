import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_5210/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/features/user_setup/presentation/widgets/add_child_bottom_sheet.dart';
import 'package:system_5210/features/user_setup/presentation/widgets/profile_child_card.dart';
import 'dart:ui';
import 'package:system_5210/core/utils/app_alerts.dart';

class EditChildrenView extends StatefulWidget {
  const EditChildrenView({super.key});

  @override
  State<EditChildrenView> createState() => _EditChildrenViewState();
}

class _EditChildrenViewState extends State<EditChildrenView> {
  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      _children = List<Map<String, dynamic>>.from(
        profileState.profile.parentProfile?['children'] ?? [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Manage Children",
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
              child: Column(
                children: [
                  Expanded(
                    child: _children.isEmpty
                        ? _buildEmptyState(l10n)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            itemCount: _children.length,
                            itemBuilder: (context, index) {
                              return ProfileChildCard(
                                child: _children[index],
                                onDelete: () => _deleteChild(index),
                                onEdit: () => _showAddChildSheet(index: index),
                              );
                            },
                          ),
                  ),
                  _buildBottomActions(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthGradientButton(
            text: l10n.addChild,
            onTap: _showAddChildSheet,
            colors: const [Color(0xFF64748B), Color(0xFF475569)],
          ),
          const SizedBox(height: 12),
          BlocBuilder<UserSetupCubit, UserSetupState>(
            builder: (context, state) {
              return AuthGradientButton(
                text: l10n.save,
                onTap: _save,
                colors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                isLoading: state is UserSetupLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppImages.iconChild,
                width: 80,
                colorFilter: ColorFilter.mode(
                  Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noChildrenAdded,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChildSheet({int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddChildBottomSheet(
        initialData: index != null ? _children[index] : null,
        onSave: (data) {
          setState(() {
            if (index != null) {
              _children[index] = data;
            } else {
              _children.add(data);
            }
          });
        },
      ),
    );
  }

  void _deleteChild(int index) {
    setState(() => _children.removeAt(index));
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    AppAlerts.showCustomDialog(
      context,
      title: "Success!",
      message: "Children data updated successfully",
      buttonText: "Great!",
      isSuccess: true,
      onPressed: () {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Go back to profile
      },
    );
  }

  void _save() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      final profile = profileState.profile;
      final updatedParentInfo = Map<String, dynamic>.from(
        profile.parentProfile ?? {},
      );
      updatedParentInfo['children'] = _children;

      context.read<UserSetupCubit>().updateUserProfile(
        uid: profile.uid,
        role: profile.role,
        parentProfileData: updatedParentInfo,
        quizAnswers: profile.quizAnswers,
        photoUrl: profile.photoUrl,
        displayName: profile.displayName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
      );
    }
  }
}
