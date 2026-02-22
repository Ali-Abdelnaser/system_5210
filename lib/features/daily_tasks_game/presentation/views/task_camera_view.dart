import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/theme/app_theme.dart';

class TaskCameraView extends StatefulWidget {
  final String title;
  final Function(String path) onPhotoTaken;

  const TaskCameraView({
    super.key,
    required this.title,
    required this.onPhotoTaken,
  });

  @override
  State<TaskCameraView> createState() => _TaskCameraViewState();
}

class _TaskCameraViewState extends State<TaskCameraView> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null) {
                return Center(child: CameraPreview(_controller!));
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.appGreen),
                );
              }
            },
          ),

          // AR-like Frame Overlay
          Center(
            child:
                Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.appGreen.withOpacity(0.5),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          // Corner brackets
                          _buildCorner(top: 0, left: 0, rotate: 0),
                          _buildCorner(top: 0, right: 0, rotate: 1.57),
                          _buildCorner(bottom: 0, left: 0, rotate: -1.57),
                          _buildCorner(bottom: 0, right: 0, rotate: 3.14),

                          Center(
                            child: Text(
                              'حط الطبق هنا',
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      duration: 2.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                    ),
          ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const AppBackButton(iconColor: Colors.white),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.title,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'صورة حلوة بتخلينا نعرف إنت أكلت إيه صحي النهاردة! 🥗',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 30),

                // Camera Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller!.takePicture();
                        widget.onPhotoTaken(image.path);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    child: Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: Center(
                        child: Container(
                          height: 65,
                          width: 65,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppTheme.appGreen,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.appGreen, width: 5),
              left: BorderSide(color: AppTheme.appGreen, width: 5),
            ),
          ),
        ),
      ),
    );
  }
}
