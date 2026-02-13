import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeroStatCard extends StatelessWidget {
  final String number;
  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const HeroStatCard({
    super.key,
    required this.number,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: color.withOpacity(0.05),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The Big Number (5-2-1-0)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      number,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

                  const Spacer(),

                  // Image
                  Center(
                    child: Image.asset(imagePath, height: 65)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.05, 1.05),
                          duration: 2.seconds,
                        ),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
