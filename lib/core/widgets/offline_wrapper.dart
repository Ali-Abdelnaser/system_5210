import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/network/network_cubit.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class OfflineWrapper extends StatelessWidget {
  final Widget child;

  const OfflineWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state == NetworkState.offline)
              const _NoInternetView(key: ValueKey('offline_view')),
            if (state == NetworkState.backOnline)
              const _BackOnlineView(key: ValueKey('back_online_view')),
          ],
        );
      },
    );
  }
}

class _NoInternetView extends StatelessWidget {
  const _NoInternetView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Placeholder (User will handle the image)
                Image.asset(
                  AppImages.noInternet,
                  width: 450,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.wifi_off_rounded,
                    size: 150,
                    color: Colors.grey[300],
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                Text(
                  l10n.noInternet,
                  textAlign: TextAlign.center,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D3142),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 12),

                Text(
                  l10n.noInternetDesc,
                  textAlign: TextAlign.center,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: () =>
                      context.read<NetworkCubit>().checkConnection(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.appRed.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded),
                      const SizedBox(width: 8),
                      Text(
                        l10n.retry,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 700.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackOnlineView extends StatelessWidget {
  const _BackOnlineView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_rounded,
                    size: 280,
                    color: Colors.green,
                  ),
                ).animate().scale(curve: Curves.easeOutBack).then().shake(),

                const SizedBox(height: 30),

                Text(
                  l10n.backOnline,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 10),

                Text(
                  l10n.backOnlineDesc,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
