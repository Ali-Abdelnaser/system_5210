import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/utils/app_validators.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_header.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;

  const ResetPasswordView({super.key, required this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
        email: widget.email,
        newPassword: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSuccess) {
          AppAlerts.showCustomDialog(
            context,
            title: "Success!",
            message: "Your password has been reset successfully.",
            buttonText: "Go to Login",
            isSuccess: true,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          );
        } else if (state is AuthFailure) {
          AppAlerts.showAlert(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthHeader(title: l10n.password),
                      const SizedBox(height: 10),
                      Text(
                        "Please enter your new password below.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        iconPath: AppImages.iconLock,
                        isPassword: true,
                        validator: (value) =>
                            AppValidators.validatePassword(value, context),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 20),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: l10n.confirmPassword,
                        iconPath: AppImages.iconLock,
                        isPassword: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      const SizedBox(height: 40),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AuthGradientButton(
                            text: "Update Password",
                            onTap: _submit,
                            colors: const [AppTheme.appRed, AppTheme.appRed],
                            isLoading: state is AuthLoading,
                          );
                        },
                      ).animate().scale(delay: 600.ms),
                      const SizedBox(height: 500),
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
}
