import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:system_5210/core/theme/app_theme.dart';

class AnalysisStepItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isProcessing;

  const AnalysisStepItem({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 15),
          Expanded(
            child: isProcessing
                ? Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.5),
                    highlightColor: Colors.white,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: AppTheme.appGreen, size: 24),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppTheme.appGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    if (isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.appYellow),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
    );
  }
}
