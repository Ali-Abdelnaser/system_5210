import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';

class ProfileImageLoader extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final double size; // Diameter of the circle
  final double loadingSize; // Size of loading indicator
  final double textSize; // Size of fallback text

  const ProfileImageLoader({
    super.key,
    required this.photoUrl,
    required this.displayName,
    required this.size,
    this.loadingSize = 40,
    this.textSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEDF2F7),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: AppLoadingIndicator(size: loadingSize));
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback();
              },
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        (displayName ?? "U")[0].toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: textSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.appBlue,
        ),
      ),
    );
  }
}
