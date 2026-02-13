import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class CounterDialog extends StatefulWidget {
  final String title;
  final Color color;
  final int initialValue;
  final String unit;
  final bool isBadHabit;
  final Function(int) onSave;

  const CounterDialog({
    super.key,
    required this.title,
    required this.color,
    required this.initialValue,
    required this.unit,
    required this.onSave,
    this.isBadHabit = false,
  });

  @override
  State<CounterDialog> createState() => _CounterDialogState();
}

class _CounterDialogState extends State<CounterDialog> {
  late int tempValue;

  @override
  void initState() {
    super.initState();
    tempValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.isBadHabit ? l10n.reduceThis : l10n.keepItUp,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.remove,
                color: Colors.grey,
                onTap: () {
                  if (tempValue > 0) {
                    setState(() => tempValue--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      "$tempValue",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      widget.unit,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildControlButton(
                icon: Icons.add,
                color: widget.color,
                onTap: () {
                  setState(() => tempValue++);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(tempValue);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.save,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
