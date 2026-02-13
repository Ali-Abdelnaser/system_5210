import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/app_images.dart';

class ProfileChildCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProfileChildCard({
    super.key,
    required this.child,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBoy = child['gender'] == 'Boy';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isBoy ? Colors.blue[50] : Colors.pink[50],
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              AppImages.iconChild,
              colorFilter: ColorFilter.mode(
                isBoy ? Colors.blue : Colors.pink,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      child['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(
                      child['disease'] ? l10n.hasCondition : l10n.healthy,
                      child['disease'] ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    // Action Menu
                    _buildActionMenu(context, l10n),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      l10n.yearsOld(int.tryParse(child['age'].toString()) ?? 0),
                    ),
                    if (child['weight'] != null &&
                        child['weight'].toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip('${child['weight']} kg'),
                    ],
                    if (child['height'] != null &&
                        child['height'].toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip('${child['height']} cm'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildActionMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF94A3B8),
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          _showDeleteDialog(context, l10n);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              const SizedBox(width: 10),
              Text(l10n.edit, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.delete,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.deleteChild, style: GoogleFonts.dynaPuff()),
        content: Text(l10n.deleteChildConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
