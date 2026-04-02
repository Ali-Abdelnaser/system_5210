import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:five2ten/core/widgets/streak_widget.dart';
import 'package:five2ten/features/notifications/presentation/manager/notification_cubit.dart';

import 'package:five2ten/features/specialists/presentation/views/admin_login_view.dart';
import 'dart:async';

class HomeAppBar extends StatefulWidget {
  final String displayName;
  final int streakCount;
  final String streakStatus;
  final bool isLoading;

  const HomeAppBar({
    super.key,
    required this.displayName,
    required this.streakCount,
    this.streakStatus = 'active',
    this.isLoading = false,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int _adminClicks = 0;
  Timer? _clickTimer;

  void _handleAdminAccess() {
    _adminClicks++;
    _clickTimer?.cancel();
    _clickTimer = Timer(const Duration(seconds: 2), () {
      _adminClicks = 0;
    });

    if (_adminClicks >= 6) {
      _adminClicks = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginView()),
      );
    }
  }

  @override
  void dispose() {
    _clickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 70,
        start: 24,
        end: 24,
        bottom: 20,
      ),
      child: Row(
        children: [
          Opacity(
            opacity: widget.isLoading ? 0 : 1,
            child: StreakWidget(
              count: widget.streakCount,
              status: widget.streakStatus,
              onTap: _handleAdminAccess,
            ),
          ),
          const Spacer(),
          _buildNotificationIcon(context),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        bool hasUnread = false;
        if (state is NotificationLoaded) {
          hasUnread = state.notifications.any((n) => !n.isRead);
        }

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 28,
                ),
                if (hasUnread)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
