import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد محاولات سابقة بعد',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
