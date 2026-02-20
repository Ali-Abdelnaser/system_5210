import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BondingImageViewer extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;
  final String title;

  const BondingImageViewer({
    super.key,
    required this.photoPaths,
    this.initialIndex = 0,
    required this.title,
  });

  @override
  State<BondingImageViewer> createState() => _BondingImageViewerState();
}

class _BondingImageViewerState extends State<BondingImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image Slider
          PhotoViewGallery(widget.photoPaths, _pageController, (index) {
            setState(() => _currentIndex = index);
          }),

          // App Bar Area (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (widget.photoPaths.length > 1)
                        Text(
                          "${_currentIndex + 1} / ${widget.photoPaths.length}",
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 48), // Spacer to balance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoViewGallery extends StatelessWidget {
  final List<String> photoPaths;
  final PageController pageController;
  final Function(int) onPageChanged;

  const PhotoViewGallery(
    this.photoPaths,
    this.pageController,
    this.onPageChanged, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: photoPaths.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Center(
            child: Image.file(
              File(photoPaths[index]),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }
}
