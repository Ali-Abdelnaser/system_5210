import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:system_5210/core/widgets/streak_widget.dart';

class HomeAppBar extends StatelessWidget {
  final String displayName;
  final int streakCount;
  final String streakStatus;
  final bool isLoading;

  const HomeAppBar({
    super.key,
    required this.displayName,
    required this.streakCount,
    this.streakStatus = 'active',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 70,
        start: 24,
        end: 24,
        bottom: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.goodMorning,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 32,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  Text(
                    displayName,
                    style: GoogleFonts.dynaPuff(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          if (!isLoading)
            StreakWidget(
              count: streakCount,
              status: streakStatus,
              onTap: () {
                // Show a small tooltip or dialog explaining the streak
              },
            ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
