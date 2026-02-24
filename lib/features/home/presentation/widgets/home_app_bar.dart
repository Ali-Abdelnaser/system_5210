import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:system_5210/core/widgets/streak_widget.dart';
import 'package:system_5210/features/notifications/presentation/manager/notification_cubit.dart';

class HomeAppBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 70,
        start: 24,
        end: 24,
        bottom: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.goodMorning,
                  style:
                      (Localizations.localeOf(context).languageCode == 'ar'
                      ? GoogleFonts.cairo
                      : GoogleFonts.dynaPuff)(
                        fontSize: 32,

                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      displayName,
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.dynaPuff)(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          if (!isLoading) ...[
            StreakWidget(
              count: streakCount,
              status: streakStatus,
              onTap: () {},
            ),
            _buildNotificationIcon(context),
          ],
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
          children: [
            Container(
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color.fromARGB(255, 81, 81, 82),
                  size: 26,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 12,
                  height: 12,
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
