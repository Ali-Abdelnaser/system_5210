import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';

class SliderDialog extends StatefulWidget {
  final String title;
  final Color color;
  final double initialValue;
  final double max;
  final Function(double) onSave;

  const SliderDialog({
    super.key,
    required this.title,
    required this.color,
    required this.initialValue,
    required this.max,
    required this.onSave,
  });

  @override
  State<SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  late double tempValue;

  @override
  void initState() {
    super.initState();
    tempValue = widget.initialValue;
  }

  String _formatDuration(double minutes, AppLocalizations l10n) {
    int h = minutes ~/ 60;
    int m = minutes.toInt() % 60;
    if (h > 0) {
      return l10n.durationFormat(h, m);
    }
    return l10n.minutesFormat(m);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        l10n.logTime,
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
          Text(
            _formatDuration(tempValue, l10n),
            style: GoogleFonts.dynaPuff(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color.withOpacity(0.2),
              thumbColor: widget.color,
              overlayColor: widget.color.withOpacity(0.1),
            ),
            child: Slider(
              value: tempValue,
              min: 0,
              max: widget.max,
              divisions: (widget.max / 15).round(),
              label: _formatDuration(tempValue, l10n),
              onChanged: (val) {
                setState(() => tempValue = val);
              },
            ),
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
}
