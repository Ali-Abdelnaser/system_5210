import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/camera_overlay.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_confirmation_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  cameraStatus _currentStatus = cameraStatus.searching;
  String _helperMessage = "AI System Initializing...";
  Timer? _analysisTimer;
  bool _isTakingPicture = false;

  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0;

  FlashMode _flashMode = FlashMode.off;
  late AnimationController _pulseController;
  late AnimationController _scanningLineController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: 2.seconds)
      ..repeat(reverse: true);
    _scanningLineController = AnimationController(
      vsync: this,
      duration: 3.seconds,
    )..repeat();
    context.read<NutritionScanCubit>().resetScanState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _helperMessage = "الذكاء الاصطناعي يبحث عن البيانات...";
        });
        _startLiveAnalysis();
      }
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      await _controller!.setFlashMode(_flashMode);
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _startLiveAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) async {
      if (_controller == null ||
          !_controller!.value.isInitialized ||
          _isProcessing ||
          _isTakingPicture)
        return;

      _isTakingPicture = true;
      try {
        final image = await _controller!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        if (!mounted) return;
        final hasText = recognizedText.text.trim().length > 10;

        setState(() {
          if (hasText) {
            _currentStatus = cameraStatus.ready;
            _helperMessage = "تم العثور على البيانات .. التقط الآن";
          } else {
            _currentStatus = cameraStatus.searching;
            _helperMessage = "وجه الكاميرا نحو المكونات بوضوح";
          }
        });
      } catch (_) {
      } finally {
        _isTakingPicture = false;
      }
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    HapticFeedback.lightImpact();

    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
      default:
        nextMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    double newZoom = _baseZoom * details.scale;
    if (newZoom < _minZoom) newZoom = _minZoom;
    if (newZoom > _maxZoom) newZoom = _maxZoom;

    if (newZoom != _currentZoom) {
      setState(() => _currentZoom = newZoom);
      _controller!.setZoomLevel(newZoom);
    }
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      _analysisTimer?.cancel();
      final image = await _controller!.takePicture();

      // Turn off flash immediately after capture
      if (_flashMode == FlashMode.torch) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _flashMode = FlashMode.off);
      }

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanConfirmationPage(imagePath: image.path),
          ),
        );
        if (mounted) {
          setState(() => _isProcessing = false);
          _startLiveAnalysis();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _startLiveAnalysis();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanningLineController.dispose();
    _analysisTimer?.cancel();
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitializing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.appBlue,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "INITIALIZING AI SCAN...",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onDoubleTap: () {
                _controller?.setZoomLevel(1.0);
                setState(() => _currentZoom = 1.0);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera Preview
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1 / _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),

                  // AI Scanning Elements
                  _buildScanningGrid(),
                  _buildScanningLine(),
                  _buildCornerBrackets(),

                  // Overlay Controls
                  CameraOverlay(
                    status: _currentStatus,
                    helperMessage: _helperMessage,
                  ),

                  // Metadata HUD
                  _buildHUD(),

                  // Zoom Indicator
                  if (_currentZoom > 1.0) _buildZoomIndicator(),

                  // Processing Animation
                  if (_isProcessing)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                    color: AppTheme.appYellow,
                                    strokeWidth: 2,
                                  )
                                  .animate(onPlay: (c) => c.repeat())
                                  .rotate(duration: 1.seconds),
                              const SizedBox(height: 24),
                              Text(
                                "EXTRACTING DATA...",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ).animate().fadeIn().scale(),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Capture Button
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: _buildCaptureButton(),
                  ),

                  // Navigation & Flash
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassButton(
                          Icons.close,
                          () => Navigator.pop(context),
                        ),
                        _buildFlashButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 110,
      right: 25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                "AI SENSORS ACTIVE",
                style: GoogleFonts.poppins(
                  color: AppTheme.appBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    duration: 1.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                  )
                  .fadeIn()
                  .fadeOut(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Focal L: Auto",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 8),
          ),
          Text(
            "ISO: Adaptive",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 8),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1.seconds);
  }

  Widget _buildScanningGrid() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.1,
        child: CustomPaint(painter: GridPainter(color: Colors.white)),
      ),
    );
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanningLineController,
      builder: (context, child) {
        return Positioned(
          top:
              MediaQuery.of(context).size.height *
              _scanningLineController.value,
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
                  Colors.transparent,
                  AppTheme.appBlue.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBrackets() {
    bool isReady = _currentStatus == cameraStatus.ready;
    Color bracketColor = isReady ? AppTheme.appGreen : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: AnimatedContainer(
        duration: 400.ms,
        padding: isReady ? const EdgeInsets.all(10) : EdgeInsets.zero,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _bracket(0, bracketColor),
            ),
            Align(
              alignment: Alignment.topRight,
              child: _bracket(1, bracketColor),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: _bracket(2, bracketColor),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _bracket(3, bracketColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bracket(int rotation, Color color) {
    return RotatedBox(
      quarterTurns: rotation,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color, width: 3),
            left: BorderSide(color: color, width: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      right: 30,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${_currentZoom.toStringAsFixed(1)}x",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.5);
  }

  Widget _buildFlashButton() {
    IconData icon;
    Color color = Colors.white;
    switch (_flashMode) {
      case FlashMode.off:
        icon = Icons.flash_off;
        color = Colors.white54;
        break;
      case FlashMode.auto:
        icon = Icons.flash_auto;
        color = AppTheme.appYellow;
        break;
      case FlashMode.torch:
        icon = Icons.flashlight_on;
        color = AppTheme.appBlue;
        break;
      default:
        icon = Icons.flash_off;
    }
    return _buildGlassButton(icon, _toggleFlash, color: color);
  }

  Widget _buildCaptureButton() {
    bool isReady = _currentStatus == cameraStatus.ready;
    return GestureDetector(
      onTap: _captureAndProcess,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isReady)
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.appGreen.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    duration: 1.seconds,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.3, 1.3),
                  )
                  .fadeOut(),

            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isReady ? AppTheme.appGreen : Colors.white,
                  width: 5,
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Center(
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReady ? AppTheme.appGreen : Colors.white,
                    boxShadow: [
                      if (isReady)
                        BoxShadow(
                          color: AppTheme.appGreen.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: isReady ? Colors.white : AppTheme.appBlue,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white.withOpacity(0.15),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 0.5;
    for (double i = 0; i <= size.width; i += 40)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i <= size.height; i += 40)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
