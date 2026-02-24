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
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:system_5210/core/widgets/app_shimmer.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _adminTapCount = 0;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh list on tab change
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tapTimer?.cancel();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  centerTitle: true,
                  leadingWidth: 70,
                  leading: const AppBackButton(),
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
                  actions: [
                    _buildDeleteAllButton(context, l10n, isAr),
                    const SizedBox(width: 16),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(85),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              dividerColor: Colors.transparent,
                              tabAlignment: TabAlignment.start,
                              indicatorSize: TabBarIndicatorSize.tab,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              indicator: BoxDecoration(
                                color: AppTheme.appBlue.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.appBlue.withOpacity(0.9),
                                    blurRadius: 8,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: const Color(0xFF64748B),
                              labelStyle:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                              tabs: [
                                _buildTab(
                                  isAr ? 'الكل' : 'All',
                                  Icons.grid_view_rounded,
                                  isAr,
                                ),
                                _buildTab(
                                  isAr ? 'نصائح' : 'Tips',
                                  Icons.lightbulb_outline_rounded,
                                  isAr,
                                ),
                                _buildTab(
                                  isAr ? 'تحديات' : 'Goals',
                                  Icons.ads_click_rounded,
                                  isAr,
                                ),
                                _buildTab(
                                  isAr ? 'النظام' : 'System',
                                  Icons.settings,
                                  isAr,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 6,
                      itemBuilder: (_, __) => AppShimmer.notificationCard(),
                    );
                  }

                  if (state is NotificationLoaded) {
                    final filteredAll = _filterNotifications(
                      state.notifications,
                    );
                    final grouped = _groupNotifications(filteredAll, isAr);

                    if (grouped.isEmpty) {
                      return _buildEmptyState(l10n, isAr);
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<NotificationCubit>().loadNotifications(),
                      color: AppTheme.appBlue,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
                            background: _buildDismissBackground(isAr),
                            onDismissed: (_) {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<NotificationCubit>()
                                  .deleteNotification(notification.id);
                            },
                            child: _buildNotificationCard(
                              context,
                              notification,
                              isAr,
                              index,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Center(
                    child: Text(isAr ? "حدث خطأ ما" : "Something went wrong"),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> all) {
    switch (_tabController.index) {
      case 1:
        return all.where((n) => n.type == 'tip').toList();
      case 2:
        return all
            .where((n) => n.type == 'challenge' || n.type == 'goal')
            .toList();
      case 3:
        return all
            .where((n) => n.type == 'broadcast' || n.type == 'system')
            .toList();
      default:
        return all;
    }
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    bool isAr,
    int index,
  ) {
    final timeStr = DateFormat('hh:mm a').format(notification.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child:
          Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassCard(
                    padding: EdgeInsets.zero,
                    opacity: 0.8,
                    blur: 15,
                    borderRadius: 20,
                    child: InkWell(
                      onTap: () {
                        context.read<NotificationCubit>().markAsRead(
                          notification.id,
                        );
                        _showNotificationSheet(context, notification, isAr);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTypeIcon(notification.type),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 35,
                                    ), // مساحة للقلب
                                    child: Text(
                                      isAr
                                          ? notification.title
                                          : (notification.titleEn ??
                                                notification.title),
                                      style:
                                          (isAr
                                          ? GoogleFonts.cairo
                                          : GoogleFonts.poppins)(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1E293B),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr
                                        ? notification.body
                                        : (notification.bodyEn ??
                                              notification.body),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        (isAr
                                        ? GoogleFonts.cairo
                                        : GoogleFonts.poppins)(
                                          fontSize: 13,
                                          color: const Color(0xFF475569),
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        timeStr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const Spacer(),
                                      if (!notification.isRead)
                                        Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.appRed
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                isAr ? "جديد" : "New",
                                                style: GoogleFonts.cairo(
                                                  color: AppTheme.appRed,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                            .animate(onPlay: (c) => c.repeat())
                                            .shimmer(
                                              duration: 1500.ms,
                                              color: Colors.white,
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildReactionButton(notification),
                  ),
                ],
              )
              .animate()
              .fadeIn(delay: (index * 50).ms, duration: 400.ms)
              .slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildTypeIcon(String type, {bool isLarge = false}) {
    Color color;
    IconData icon;
    if (type == 'tip') {
      color = AppTheme.appBlue;
      icon = Icons.lightbulb_rounded;
    } else if (type == 'broadcast' || type == 'system') {
      color = Colors.orange;
      icon = Icons.campaign_rounded;
    } else {
      color = AppTheme.appGreen;
      icon = Icons.stars_rounded;
    }

    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(isLarge ? 24 : 14),
      ),
      child: Icon(icon, color: color, size: isLarge ? 40 : 22),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppTheme.appBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: AppTheme.appBlue.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? "الصندوق فارغ" : "Inbox is empty",
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ).animate().fadeIn().scale(delay: 100.ms),
    );
  }

  Widget _buildSectionHeader(String title, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppTheme.appBlue.withOpacity(0.7),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDeleteAllButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return IconButton(
      onPressed: () => _showClearAllDialog(context, l10n, isAr),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.appRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppTheme.appRed,
          size: 20,
        ),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? "تفريغ الصندوق" : "Clear All",
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isAr ? "هل تريد مسح جميع الإشعارات؟" : "Clear all notifications?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().clearAll();
              Navigator.pop(context);
            },
            child: Text(
              isAr ? "مسح" : "Clear",
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

  void _showNotificationSheet(
    BuildContext context,
    AppNotification notification,
    bool isAr,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationDetailsSheet(
        initialNotification: notification,
        isAr: isAr,
        typeIconBuilder: _buildTypeIcon,
      ),
    );
  }

  Widget _buildDismissBackground(bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.appRed,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  List<dynamic> _groupNotifications(
    List<AppNotification> notifications,
    bool isAr,
  ) {
    if (notifications.isEmpty) return [];
    final List<dynamic> grouped = [];
    String? lastHeader;
    final today = DateTime.now();
    for (var n in notifications) {
      String header = (n.timestamp.day == today.day)
          ? (isAr ? "اليوم" : "Today")
          : (isAr ? "سابقاً" : "Earlier");
      if (lastHeader != header) {
        grouped.add(header);
        lastHeader = header;
      }
      grouped.add(n);
    }
    return grouped;
  }

  Widget _buildTab(String label, IconData icon, bool isAr) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
    );
  }

  Widget _buildReactionButton(AppNotification notification) {
    final isLiked = notification.isLiked;
    return InkWell(
      onTap: () {
        context.read<NotificationCubit>().toggleLike(notification.id);
        if (!isLiked) HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLiked
              ? AppTheme.appRed.withOpacity(0.12)
              : const Color.fromARGB(255, 62, 63, 63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLiked
                ? AppTheme.appRed.withOpacity(0.3)
                : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Icon(
          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isLiked
              ? AppTheme.appRed
              : const Color.fromARGB(255, 58, 59, 59),
        ),
      ),
    );
  }
}

class NotificationDetailsSheet extends StatelessWidget {
  final AppNotification initialNotification;
  final bool isAr;
  final Widget Function(String, {bool isLarge}) typeIconBuilder;

  const NotificationDetailsSheet({
    super.key,
    required this.initialNotification,
    required this.isAr,
    required this.typeIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        // البحث عن النسخة المحدثة من الإشعار في الـ State
        AppNotification notification = initialNotification;
        if (state is NotificationLoaded) {
          notification = state.notifications.firstWhere(
            (n) => n.id == initialNotification.id,
            orElse: () => initialNotification,
          );
        }
        final isLiked = notification.isLiked;

        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      typeIconBuilder(notification.type, isLarge: true),
                      const SizedBox(height: 15),
                      Text(
                        isAr
                            ? notification.title
                            : (notification.titleEn ?? notification.title),
                        textAlign: TextAlign.center,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Text(
                          isAr
                              ? notification.body
                              : (notification.bodyEn ?? notification.body),
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 15,
                                height: 1.6,
                                color: const Color(0xFF334155),
                              ),
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              if (notification.actionUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => launchUrl(
                        Uri.parse(notification.actionUrl!),
                        mode: LaunchMode.externalApplication,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isAr ? 'ذهاب' : 'Go Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        isAr ? 'إغلاق' : 'Close',
                        style: GoogleFonts.cairo(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                        onPressed: () {
                          context.read<NotificationCubit>().toggleLike(
                            notification.id,
                          );
                          HapticFeedback.mediumImpact();
                        },
                        icon: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked ? AppTheme.appRed : Colors.grey[400],
                          size: 28,
                        ),
                      )
                      .animate(target: isLiked ? 1 : 0)
                      .scale(duration: 200.ms, curve: Curves.easeOutBack),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
