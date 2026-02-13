import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../presentation/manager/user_setup_cubit.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_images.dart';
import '../../../auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/features/user_setup/presentation/widgets/discovery_input_field.dart';
import '../../../../core/widgets/app_back_button.dart';

class ChildQuizView extends StatefulWidget {
  const ChildQuizView({super.key});

  @override
  State<ChildQuizView> createState() => _ChildQuizViewState();
}

class _ChildQuizViewState extends State<ChildQuizView> {
  final _formKey = GlobalKey<FormState>();
  final _hobbyController = TextEditingController();
  final _feelingController = TextEditingController();
  final _foodController = TextEditingController();
  final _powerController = TextEditingController();

  @override
  void dispose() {
    _hobbyController.dispose();
    _feelingController.dispose();
    _foodController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  void _onFinish() {
    if (_formKey.currentState!.validate()) {
      final answers = {
        'favoriteHobby': _hobbyController.text,
        'heroFeeling': _feelingController.text,
        'favoriteFood': _foodController.text,
        'superPower': _powerController.text,
      };
      final cubit = context.read<UserSetupCubit>();
      cubit.updateQuizAnswers(answers);

      cubit.submitSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        if (state is UserSetupSuccess) {
          Navigator.pushReplacementNamed(context, AppRoutes.congratulations);
        } else if (state is UserSetupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.appRed,
            ),
          );
        }
      },
      child: Scaffold(
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
                        l10n.discoveryTitle,
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
                            label: l10n.favoriteHobbyQuestion,
                            hint: l10n.hobbyHint,
                            isArabic: isArabic,
                            controller: _hobbyController,
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
                            label: l10n.heroFeelingQuestion,
                            hint: l10n.heroHint,
                            isArabic: isArabic,
                            controller: _feelingController,
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
                            label: l10n.favoriteFoodQuestion,
                            hint: l10n.foodHint,
                            isArabic: isArabic,
                            controller: _foodController,
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
                            label: l10n.superPowerQuestion,
                            hint: l10n.powerHint,
                            isArabic: isArabic,
                            controller: _powerController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please answer this question";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    BlocBuilder<UserSetupCubit, UserSetupState>(
                      builder: (context, state) {
                        return AuthGradientButton(
                          text: l10n.finish,
                          onTap: _onFinish,
                          colors: const [AppTheme.appRed, AppTheme.appRed],
                          isLoading: state is UserSetupLoading,
                        );
                      },
                    ).animate().fadeIn(delay: 400.ms).scale(),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
