import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:system_5210/core/utils/app_audio.dart';

class CustomScratcher extends StatefulWidget {
  final Widget child;
  final String? coverImagePath;
  final Color coverColor;
  final double brushSize;
  final VoidCallback? onScratchUpdate;
  final VoidCallback? onScratchStart;
  final VoidCallback? onScratchEnd;
  final double threshold;
  final VoidCallback? onThresholdReached;
  final Function(double)? onProgressUpdate;
  final List<List<Offset>> initialPaths;
  final Function(List<List<Offset>>)? onPathsUpdate;

  const CustomScratcher({
    super.key,
    required this.child,
    this.coverImagePath,
    this.coverColor = const Color(0xFFC0C0C0),
    this.brushSize = 50,
    this.onScratchUpdate,
    this.onScratchStart,
    this.onScratchEnd,
    this.threshold = 0.96, // High threshold for "100%" feel
    this.onThresholdReached,
    this.onProgressUpdate,
    this.initialPaths = const [],
    this.onPathsUpdate,
  });

  @override
  State<CustomScratcher> createState() => _CustomScratcherState();
}

class _CustomScratcherState extends State<CustomScratcher> {
  List<List<Offset>> paths = [];
  ui.Image? _coverImage;
  bool _loadingImage = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isFinished = false;
  // Using a 20x20 grid (400 points) for much higher precision
  final List<bool> _grid = List.filled(400, false);

  @override
  void initState() {
    super.initState();
    if (widget.coverImagePath != null) {
      _loadImage(widget.coverImagePath!);
    }
    // Load initial paths if any
    if (widget.initialPaths.isNotEmpty) {
      paths = List<List<Offset>>.from(
        widget.initialPaths.map((p) => List<Offset>.from(p)),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadImage(String path) async {
    if (mounted) setState(() => _loadingImage = true);
    try {
      final ByteData data = await rootBundle.load(path);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _coverImage = fi.image;
          _loadingImage = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading scratch image: $e");
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  void _addPoint(Offset globalPosition) {
    if (_isFinished) {
      _stopScratchSound();
      return;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPos = renderBox.globalToLocal(globalPosition);
    Size size = renderBox.size;

    if (paths.isNotEmpty) {
      setState(() {
        paths.last.add(localPos);
        _updateGrid(localPos, size);
      });

      if (!_isFinished) {
        _startScratchSound();
      }
      widget.onScratchUpdate?.call();
      widget.onPathsUpdate?.call(paths);
    }
  }

  void _updateGrid(Offset pos, Size size) {
    if (_isFinished) return;
    int columns = 20;
    int rows = 20;
    int x = (pos.dx / size.width * columns).floor().clamp(0, columns - 1);
    int y = (pos.dy / size.height * rows).floor().clamp(0, rows - 1);

    int index = y * columns + x;
    if (index < _grid.length) {
      _grid[index] = true;
    }

    double progress = _grid.where((e) => e).length / (columns * rows);
    widget.onProgressUpdate?.call(progress);

    if (progress >= widget.threshold) {
      setState(() {
        _isFinished = true;
      });
      _stopScratchSound();
      widget.onThresholdReached?.call();
    }
  }

  Future<void> _startScratchSound() async {
    if (!_isPlaying && !_isFinished) {
      _isPlaying = true;
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(
        AssetSource(AppAudio.scratch.replaceFirst('assets/', '')),
      );
    }
  }

  void _stopScratchSound() {
    if (_isPlaying) {
      _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingImage) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Listener(
      onPointerDown: (event) {
        if (_isFinished) return;
        widget.onScratchStart?.call();
        setState(() {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          paths.add([renderBox.globalToLocal(event.position)]);
        });
      },
      onPointerMove: (event) {
        _addPoint(event.position);
      },
      onPointerUp: (event) {
        _stopScratchSound();
        widget.onScratchEnd?.call();
      },
      onPointerCancel: (event) {
        _stopScratchSound();
        widget.onScratchEnd?.call();
      },
      child: Stack(
        children: [
          // Content is ALWAYS behind
          widget.child,
          // Scratch layer is ALWAYS on top, but it has holes
          if (!_isFinished)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: _ScratchPainter(
                      paths: paths,
                      coverColor: widget.coverColor,
                      coverImage: _coverImage,
                      brushSize: widget.brushSize,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<List<Offset>> paths;
  final Color coverColor;
  final ui.Image? coverImage;
  final double brushSize;

  _ScratchPainter({
    required this.paths,
    required this.coverColor,
    this.coverImage,
    required this.brushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw Cover
    if (coverImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: coverImage!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = coverColor,
      );
    }

    // 2. Draw Eraser
    Paint eraserPaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = brushSize
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      if (path.isEmpty) continue;

      final scratchPath = Path();
      scratchPath.moveTo(path.first.dx, path.first.dy);
      for (int i = 1; i < path.length; i++) {
        scratchPath.lineTo(path[i].dx, path[i].dy);
      }
      canvas.drawPath(scratchPath, eraserPaint);

      // Circles for better finish
      for (final point in path) {
        canvas.drawCircle(
          point,
          brushSize / 2,
          eraserPaint..style = PaintingStyle.fill,
        );
        eraserPaint.style = PaintingStyle.stroke;
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) => true;
}
