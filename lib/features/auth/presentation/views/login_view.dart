import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_validators.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_header.dart';
import 'package:system_5210/features/auth/presentation/widgets/contact_toggle.dart';
import 'package:system_5210/features/auth/presentation/widgets/social_login_section.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_footer_link.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isEmailMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            // Show professional welcome message
            AppAlerts.showAlert(
              context,
              message: AppLocalizations.of(context)!.welcomeBack,
              type: AlertType.success,
            );

            // Small delay for the user to see the success message and avoid "snapping"
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (!context.mounted) return;
              if (state.dataExists) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.roleSelection,
                );
              }
            });
          }
        } else if (state is AuthPhoneCodeSent) {
          Navigator.pushNamed(
            context,
            AppRoutes.verification,
            arguments: {
              'isEmail': false,
              'verificationId': state.verificationId,
            },
          );
        } else if (state is AuthFailure) {
          AppAlerts.showAlert(context, message: state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          extendBody: true,
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
                        const SizedBox(height: 40),
                        AuthHeader(title: l10n.loginTitle),
                        const SizedBox(height: 30),
                        ContactToggle(
                          isEmailMode: isEmailMode,
                          onChanged: (v) => setState(() => isEmailMode = v),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: isEmailMode
                              ? _emailController
                              : _phoneController,
                          label: isEmailMode
                              ? l10n.parentsEmail
                              : l10n.phoneNumber,
                          iconPath: isEmailMode
                              ? AppImages.iconEmail
                              : AppImages.iconPhone,
                          isNumeric: !isEmailMode,
                          validator: (value) => isEmailMode
                              ? AppValidators.validateEmail(value, context)
                              : AppValidators.validatePhone(value, context),
                          textInputAction: TextInputAction.next,
                          autofillHints: isEmailMode
                              ? [AutofillHints.email]
                              : [AutofillHints.telephoneNumber],
                        ),
                        if (isEmailMode) ...[
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: l10n.password,
                            iconPath: AppImages.iconLock,
                            isPassword: true,
                            validator: (value) =>
                                AppValidators.validatePassword(value, context),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onLogin(context),
                            autofillHints: const [AutofillHints.password],
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.forgotPassword,
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                l10n.forgotPassword,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        AuthGradientButton(
                          text: l10n.launchNow,
                          onTap: () => _onLogin(context),
                          colors: const [AppTheme.appRed, AppTheme.appRed],
                          isLoading: state is AuthLoading,
                        ).animate().scale(
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 10),
                        const SocialLoginSection(),
                        const SizedBox(height: 10),
                        AuthFooterLink(
                          text: l10n.newHeroQuestion,
                          actionText: l10n.registerHere,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLogin(BuildContext context) {
    if (isEmailMode) {
      if (!_formKey.currentState!.validate()) return;
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      if (!_formKey.currentState!.validate()) return;
      context.read<AuthCubit>().sendPhoneVerificationForLogin(
        _phoneController.text.trim(),
      );
    }
  }
}
