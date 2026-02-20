import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_validators.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/app_back_button.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_header.dart';
import 'package:system_5210/features/auth/presentation/widgets/contact_toggle.dart';
import 'package:system_5210/features/auth/presentation/widgets/social_login_section.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:system_5210/core/utils/app_utils.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool isEmailMode = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              message: AppLocalizations.of(context)!.welcomeMission,
              type: AlertType.success,
            );

            // Small delay for the user to see the success message
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
            });
          }
        } else if (state is AuthPhoneCodeSent) {
          Navigator.pushNamed(
            context,
            AppRoutes.verification,
            arguments: {
              'isEmail': false,
              'verificationId': state.verificationId,
              'phoneNumber': _phoneController.text.trim(),
            },
          );
        } else if (state is AuthEmailVerificationSent) {
          Navigator.pushNamed(
            context,
            AppRoutes.verification,
            arguments: {
              'isEmail': true,
              'verificationId': null,
              'email': _emailController.text.trim(),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 50,
            leading: const AppBackButton(),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppImages.authBackground, fit: BoxFit.fill),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        AuthHeader(title: l10n.createAccount),
                        const SizedBox(height: 30),
                        ContactToggle(
                          isEmailMode: isEmailMode,
                          onChanged: (v) => setState(() => isEmailMode = v),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _nameController,
                          label: l10n.fullName,
                          iconPath: AppImages.iconUser,
                          validator: (value) =>
                              AppValidators.validateName(value, context),
                          textInputAction: TextInputAction.next,
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            label: l10n.confirmPassword,
                            iconPath: AppImages.iconLock,
                            isPassword: true,
                            validator: (value) =>
                                AppValidators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                  context,
                                ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onRegister(context),
                          ),
                        ],
                        const SizedBox(height: 24),
                        AuthGradientButton(
                          text: l10n.startAdventure,
                          onTap: () => _onRegister(context),
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
                          text: l10n.alreadyHaveAccount,
                          actionText: l10n.login,
                          onTap: () => Navigator.pop(context),
                        ),
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

  void _onRegister(BuildContext context) async {
    if (!await AppUtils.checkInternet(context)) return;
    if (isEmailMode) {
      if (!_formKey.currentState!.validate()) return;
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } else {
      if (!_formKey.currentState!.validate()) return;
      context.read<AuthCubit>().setPendingDisplayName(
        _nameController.text.trim(),
      );
      context.read<AuthCubit>().sendPhoneVerificationCode(
        _phoneController.text.trim(),
      );
    }
  }
}
