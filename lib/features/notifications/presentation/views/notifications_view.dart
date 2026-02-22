import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../manager/notification_cubit.dart';
import '../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

import 'package:system_5210/features/specialists/presentation/views/admin_broadcast_login_view.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:flutter/services.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int _adminTapCount = 0;
  Timer? _tapTimer;

  void _handleTitleTap() {
    _adminTapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(seconds: 2), () {
      _adminTapCount = 0;
    });

    if (_adminTapCount >= 4) {
      _adminTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminBroadcastLoginView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: Text(
            l10n.notifications,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        leading: const AppBackButton(),
        actions: [
          _buildDeleteAllButton(context, l10n, isAr),
          const SizedBox(width: 16),
        ],
      ),

      body: Stack(
        children: [
          // Standard App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotificationFailure) {
                  return Center(child: Text(state.message));
                }

                if (state is NotificationLoaded) {
                  final notifications = state.notifications;

                  if (notifications.isEmpty) {
                    return _buildEmptyState(context, l10n, isAr);
                  }

                  // Group notifications by date
                  final grouped = _groupNotifications(notifications, isAr);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final item = grouped[index];
                      if (item is String) {
                        return _buildSectionHeader(item, isAr);
                      }

                      final notification = item as AppNotification;
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          HapticFeedback.mediumImpact();
                          context.read<NotificationCubit>().deleteNotification(
                            notification.id,
                          );
                        },
                        background: _buildDismissBackground(isAr),
                        child:
                            _buildNotificationCard(context, notification, isAr)
                                .animate()
                                .fadeIn(delay: (index * 40).ms)
                                .slideY(begin: 0.1),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAllButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return Center(
      child: GestureDetector(
        onTap: () => _showClearAllDialog(context, l10n, isAr),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.appRed.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.appRed.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Icon(Icons.delete, color: AppTheme.appRed, size: 22),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppTheme.appBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 100,
              color: AppTheme.appBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isAr ? "لا توجد إشعارات حالياً" : "No notifications yet",
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? "ستصلك هنا النصائح اليومية المهمة لكِ"
                : "Daily tips will appear here",
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 140),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    bool isAr,
  ) {
    final timeStr = DateFormat('hh:mm a').format(notification.timestamp);
    final dateStr = DateFormat('MMM dd, yyyy').format(notification.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: EdgeInsets.zero,
        opacity: 0.75,
        blur: 12,
        borderRadius: 22,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<NotificationCubit>().markAsRead(notification.id);
              _showNotificationSheet(context, notification, isAr);
            },
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (notification.type == 'tip'
                                  ? AppTheme.appBlue
                                  : notification.type == 'broadcast'
                                  ? Colors.orange
                                  : AppTheme.appGreen)
                              .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.type == 'tip'
                          ? Icons.lightbulb_rounded
                          : notification.type == 'broadcast'
                          ? Icons.campaign_rounded
                          : Icons.stars_rounded,
                      color: notification.type == 'tip'
                          ? AppTheme.appBlue
                          : notification.type == 'broadcast'
                          ? Colors.orange
                          : AppTheme.appGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isAr
                                    ? notification.title
                                    : (notification.titleEn ??
                                          notification.title),
                                textAlign: isAr
                                    ? TextAlign.center
                                    : TextAlign.center,
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.appRed,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                  .animate(onPlay: (c) => c.repeat())
                                  .scale(
                                    duration: 1.seconds,
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.2, 1.2),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAr
                              ? notification.body
                              : (notification.bodyEn ?? notification.body),
                          textAlign: isAr ? TextAlign.left : TextAlign.right,
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 14,
                                color: const Color(0xFF475569),
                                height: 1.5,
                              ),
                        ),
                        if (notification.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              notification.imageUrl!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[100],
                                      child: const AppLoadingIndicator(
                                        size: 40,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$dateStr • $timeStr",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSheet(
    BuildContext context,
    AppNotification notification,
    bool isAr,
  ) {
    final timeStr = DateFormat('hh:mm a').format(notification.timestamp);
    final dateStr = DateFormat('MMM dd, yyyy').format(notification.timestamp);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    (notification.type == 'tip'
                            ? AppTheme.appBlue
                            : notification.type == 'broadcast'
                            ? Colors.orange
                            : AppTheme.appGreen)
                        .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.type == 'tip'
                    ? Icons.lightbulb_rounded
                    : notification.type == 'broadcast'
                    ? Icons.campaign_rounded
                    : Icons.stars_rounded,
                color: notification.type == 'tip'
                    ? AppTheme.appBlue
                    : notification.type == 'broadcast'
                    ? Colors.orange
                    : AppTheme.appGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAr
                  ? notification.title
                  : (notification.titleEn ?? notification.title),
              textAlign: TextAlign.center,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "$dateStr  |  $timeStr",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (notification.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  notification.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[100],
                      child: const AppLoadingIndicator(size: 50),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAr
                    ? notification.body
                    : (notification.bodyEn ?? notification.body),
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (notification.actionUrl != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(notification.actionUrl!);
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      debugPrint('Error launching from sheet: $e');
                    }
                  },
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isAr ? 'عرض التفاصيل' : 'View Details',
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.appBlue.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isAr ? 'إغلاق' : 'Close',
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<dynamic> _groupNotifications(
    List<AppNotification> notifications,
    bool isAr,
  ) {
    final List<dynamic> grouped = [];
    String? lastHeader;

    final today = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    for (var n in notifications) {
      String header;
      if (n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day) {
        header = isAr ? "اليوم" : "Today";
      } else if (n.timestamp.year == yesterday.year &&
          n.timestamp.month == yesterday.month &&
          n.timestamp.day == yesterday.day) {
        header = isAr ? "أمس" : "Yesterday";
      } else {
        header = isAr ? "سابقاً" : "Earlier";
      }

      if (lastHeader != header) {
        grouped.add(header);
        lastHeader = header;
      }
      grouped.add(n);
    }
    return grouped;
  }

  Widget _buildSectionHeader(String title, bool isAr) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 8, right: 8),
      child: Row(
        children: [
          Text(
            title,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.appBlue,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.appBlue.withOpacity(0.3),
                    AppTheme.appBlue.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.appRed,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isAr ? "مسح التنبيهات" : "Clear Notifications",
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isAr
              ? "هل أنت متأكد من مسح جميع الإشعارات؟"
              : "Are you sure you want to clear all notifications?",
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().clearAll();
              Navigator.pop(context);
            },
            child: Text(
              isAr ? "مسح الكل" : "Clear All",
              style: const TextStyle(
                color: AppTheme.appRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
