import 'package:flutter/material.dart';
import 'dart:ui';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const AppBackButton({
    super.key,
    this.onTap,
    this.iconColor,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';

    return Center(
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    isAr
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: iconColor ?? const Color(0xFF1E293B),
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
