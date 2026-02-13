import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';

enum cameraStatus { initializing, searching, textDetected, ready }

class CameraOverlay extends StatelessWidget {
  final cameraStatus status;
  final String helperMessage;

  const CameraOverlay({
    super.key,
    this.status = cameraStatus.searching,
    this.helperMessage = "Place the ingredients label inside the frame",
  });

  Color _getFrameColor() {
    switch (status) {
      case cameraStatus.initializing:
        return Colors.grey;
      case cameraStatus.searching:
        return Colors.grey.withOpacity(0.5);
      case cameraStatus.textDetected:
        return AppTheme.appYellow;
      case cameraStatus.ready:
        return AppTheme.appGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaWidth = size.width * 0.85;
    final scanAreaHeight = size.height * 0.45;

    return Stack(
      children: [
        // Dark background with hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: scanAreaWidth,
                  height: scanAreaHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Frame
        Align(
          alignment: Alignment.center,
          child: Container(
            width: scanAreaWidth,
            height: scanAreaHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: _getFrameColor().withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                _buildCorner(top: 0, left: 0, rotate: 0),
                _buildCorner(top: 0, right: 0, rotate: 1.57),
                _buildCorner(bottom: 0, left: 0, rotate: -1.57),
                _buildCorner(bottom: 0, right: 0, rotate: 3.14),

                if (status == cameraStatus.ready ||
                    status == cameraStatus.textDetected)
                  const ScanningLine(),
              ],
            ),
          ),
        ),
        // Instructions & Feedback
        Positioned(
          top: size.height * 0.18,
          left: 40,
          right: 40,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  helperMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Text Detected Badge
        if (status == cameraStatus.ready || status == cameraStatus.textDetected)
          Positioned(
            top: size.height * 0.5 - scanAreaHeight / 2 - 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: status == cameraStatus.ready
                        ? AppTheme.appGreen
                        : AppTheme.appYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status == cameraStatus.ready
                            ? "READY TO SCAN"
                            : "TEXT DETECTED",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double rotate,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotate,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: _getFrameColor(), width: 6),
              left: BorderSide(color: _getFrameColor(), width: 6),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanningLine extends StatefulWidget {
  const ScanningLine({super.key});

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top:
              _controller.value *
              (MediaQuery.of(context).size.height * 0.4 - 2),
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.appBlue.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  AppTheme.appBlue.withOpacity(0),
                  AppTheme.appBlue,
                  AppTheme.appBlue.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
