import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_validators.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/app_back_button.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().forgotPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 700;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          Navigator.pushNamed(
            context,
            AppRoutes.verification,
            arguments: {
              'isEmail': true,
              'isPasswordReset': true,
              'email': _emailController.text.trim(),
            },
          );
        } else if (state is AuthFailure) {
          AppAlerts.showAlert(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,
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
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          AppImages.logo,
                          height: isSmallScreen ? 120 : 150,
                        ),
                      ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.forgotPasswordTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dynaPuff(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3142),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 15),
                      Text(
                        l10n.forgotPasswordDesc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                      AuthTextField(
                        controller: _emailController,
                        label: l10n.parentsEmail,
                        iconPath: AppImages.iconEmail,
                        validator: (value) =>
                            AppValidators.validateEmail(value, context),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 40),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AuthGradientButton(
                            text: l10n.sendCode,
                            onTap: _submit,
                            colors: const [AppTheme.appRed, AppTheme.appRed],
                            isLoading: state is AuthLoading,
                          );
                        },
                      ).animate().scale(
                        delay: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l10n.backToLogin,
                          style: GoogleFonts.poppins(
                            color: AppTheme.appRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
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
