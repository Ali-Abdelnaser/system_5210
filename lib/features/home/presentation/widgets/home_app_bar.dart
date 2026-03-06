import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/widgets/streak_widget.dart';
import 'package:system_5210/features/notifications/presentation/manager/notification_cubit.dart';

import 'package:system_5210/features/specialists/presentation/views/admin_login_view.dart';
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

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color.fromARGB(255, 81, 81, 82),
                size: 38,
              ),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (hasUnread)
              Positioned(
                right: 2,
                top: 2,
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
        );
      },
    );
  }
}
