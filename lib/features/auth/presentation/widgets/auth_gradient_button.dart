import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';

class AuthGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool isLoading;

  const AuthGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.colors,
    this.isLoading = false,
  });

  @override
  State<AuthGradientButton> createState() => _AuthGradientButtonState();
}

class _AuthGradientButtonState extends State<AuthGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading) _controller.reverse();
  }

  void _onTapCancel() {
    if (!widget.isLoading) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading
            ? null
            : () {
                Feedback.forTap(context);
                widget.onTap();
              },
        child: Container(
          height: 52, // Fixed height to prevent shrinking
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withOpacity(0.35),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const AppLoadingIndicator(size: 28) // Your custom indicator
                : Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
