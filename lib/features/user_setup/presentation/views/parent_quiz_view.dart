import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../presentation/manager/user_setup_cubit.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_images.dart';
import 'package:system_5210/features/user_setup/presentation/widgets/discovery_input_field.dart';
import '../../../auth/presentation/widgets/auth_gradient_button.dart';
import '../../../../core/widgets/app_back_button.dart';

class ParentQuizView extends StatefulWidget {
  const ParentQuizView({super.key});

  @override
  State<ParentQuizView> createState() => _ParentQuizViewState();
}

class _ParentQuizViewState extends State<ParentQuizView> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _challengeController = TextEditingController();
  final _activityController = TextEditingController();
  final _specialController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    _challengeController.dispose();
    _activityController.dispose();
    _specialController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final answers = {
        'healthGoal': _goalController.text,
        'challenge': _challengeController.text,
        'activity': _activityController.text,
        'notes': _specialController.text,
      };
      context.read<UserSetupCubit>().updateQuizAnswers(answers);
      Navigator.pushNamed(context, AppRoutes.parentProfileSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  Center(
                    child: Text(
                      l10n.parentInfoTitle,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                  ),

                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question 1
                        DiscoveryInputField(
                          label: l10n.healthGoalQuestion,
                          hint: l10n.goalHint,
                          isArabic: isArabic,
                          controller: _goalController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please answer this question"; // Localize if needed
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Question 2
                        DiscoveryInputField(
                          label: l10n.challengeQuestion,
                          hint: l10n.challengeHint,
                          isArabic: isArabic,
                          controller: _challengeController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please answer this question";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Question 3
                        DiscoveryInputField(
                          label: l10n.activityQuestion,
                          hint: l10n.activityHint,
                          isArabic: isArabic,
                          controller: _activityController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please answer this question";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Question 4
                        DiscoveryInputField(
                          label: l10n.specialInfoQuestion,
                          hint: l10n.specialHint,
                          isArabic: isArabic,
                          controller: _specialController,
                          // Optional field, no validator
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const SizedBox(height: 40),

                  AuthGradientButton(
                    text: l10n.continueToProfile,
                    onTap: _onContinue,
                    colors: const [AppTheme.appRed, AppTheme.appRed],
                  ).animate().fadeIn(delay: 400.ms).scale(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
