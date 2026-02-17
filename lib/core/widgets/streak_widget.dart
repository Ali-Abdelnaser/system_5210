import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class StreakWidget extends StatelessWidget {
  final int count;
  final String status; // 'active', 'frozen'
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    required this.count,
    this.status = 'active',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isFrozen = status == 'frozen';

    // الألوان الأصلية البسيطة
    final Color bgColor = isFrozen
        ? const Color(0xFFE0F7FA)
        : const Color(0xFFFFE5D0);
    final Color borderColor = isFrozen
        ? Colors.blue.withOpacity(0.3)
        : Colors.orange.withOpacity(0.3);
    final Color iconColor = isFrozen ? Colors.blue : Colors.orange;
    final Color textColor = isFrozen ? Colors.blue[800]! : Colors.orange[800]!;
    final IconData icon = isFrozen
        ? Icons.ac_unit_rounded
        : Icons.local_fire_department_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                ),
            const SizedBox(width: 4),
            Text(
              '$count ${l10n.streakLabel}',
              style: GoogleFonts.dynaPuff(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
    );
  }
}
