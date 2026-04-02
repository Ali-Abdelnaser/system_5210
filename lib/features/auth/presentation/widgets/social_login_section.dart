import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:five2ten/features/auth/domain/usecases/login_with_social_usecase.dart';
import 'package:five2ten/features/auth/presentation/manager/auth_cubit.dart';
import 'package:five2ten/l10n/app_localizations.dart';
import '../../../../core/utils/app_images.dart';
import 'social_login_button.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: Color.fromARGB(255, 0, 0, 0), thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                l10n.orContinueWith,
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: Color.fromARGB(255, 0, 0, 0), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SocialLoginButton(
          onTap: () => context.read<AuthCubit>().socialLogin(SocialType.google),
          iconPath: AppImages.googleIcon,
          color: Colors.white,
          label: 'Google',
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }
}
