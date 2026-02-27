import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/features/healthy_insights/domain/entities/healthy_insight.dart';

class InsightCard extends StatefulWidget {
  final HealthyInsight insight;
  final int index;

  const InsightCard({super.key, required this.insight, required this.index});

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool _isExpanded = false;

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.insight.sourceLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _isExpanded
                  ? AppTheme.appBlue.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isExpanded ? 30 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: GlassContainer(
          blur: 20,
          opacity: 0.8,
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isExpanded
                ? AppTheme.appBlue.withOpacity(0.4)
                : Colors.white.withOpacity(0.6),
            width: 1.5,
          ),
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            widget.insight.category,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: _getCategoryColor(
                              widget.insight.category,
                            ).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(widget.insight.category),
                              size: 14,
                              color: _getCategoryColor(widget.insight.category),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.insight.category,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(
                                  widget.insight.category,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _isExpanded
                            ? AppTheme.appBlue
                            : Colors.blueGrey[300],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Question Text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.appBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.insight.question,
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Expanded Answer
                  AnimatedCrossFade(
                    firstChild: const SizedBox(
                      width: double.infinity,
                      height: 0,
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1.5,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.insight.answer,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Source Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppTheme.appBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "المصدر الرسمي:",
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[300],
                                        ),
                                      ),
                                      Text(
                                        widget.insight.sourceName,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: AppTheme.appBlue,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: _launchUrl,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.open_in_new_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'السمنة':
        return const Color(0xFFEF4444);
      case 'التغذية':
        return const Color(0xFF10B981);
      case 'الصحة الرقمية':
        return const Color(0xFF8B5CF6);
      case 'النشاط البدني':
        return const Color(0xFFF59E0B);
      case 'الصحة العامة':
        return const Color(0xFF3B82F6);
      default:
        return AppTheme.appBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'السمنة':
        return Icons.monitor_weight_rounded;
      case 'التغذية':
        return Icons.restaurant_rounded;
      case 'الصحة الرقمية':
        return Icons.devices_rounded;
      case 'النشاط البدني':
        return Icons.directions_run_rounded;
      case 'الصحة العامة':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
