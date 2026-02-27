import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/services/notification_service.dart';
import 'package:system_5210/core/utils/injection_container.dart' as di;
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView>
    with WidgetsBindingObserver {
  final LocalStorageService _storage = di.sl<LocalStorageService>();
  final NotificationService _notificationService = di.sl<NotificationService>();

  bool _allNotifications = true;
  bool _soundsEnabled = true;
  bool _streakNotifications = true;
  bool _taskNotifications = true;
  bool _insightsNotifications = true;

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.get(
      'app_settings',
      'notification_settings',
    );
    if (settings != null) {
      setState(() {
        _allNotifications = settings['all'] ?? true;
        _soundsEnabled = settings['sounds'] ?? true;
        _streakNotifications = settings['streak'] ?? true;
        _taskNotifications = settings['tasks'] ?? true;
        _insightsNotifications = settings['insights'] ?? true;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _storage.save('app_settings', 'notification_settings', {
      'all': _allNotifications,
      'sounds': _soundsEnabled,
      'streak': _streakNotifications,
      'tasks': _taskNotifications,
      'insights': _insightsNotifications,
    });

    // If master switch turned off, cancel all local notifications
    if (!_allNotifications) {
      await _notificationService.cancelAll();
    }
  }

  Future<void> _checkPermissions() async {
    final activityStatus = await Permission.activityRecognition.status;
    final sensorsStatus = await Permission.sensors.status;
    final cameraStatus = await Permission.camera.status;
    final notifStatus = await Permission.notification.status;

    // For storage, handle Android 13+ (photos) vs older (storage)
    PermissionStatus photoStatus;
    if (await Permission.photos.isGranted) {
      photoStatus = PermissionStatus.granted;
    } else {
      photoStatus = await Permission.storage.status;
    }

    if (mounted) {
      setState(() {
        _permissionStatuses = {
          Permission.activityRecognition: activityStatus,
          Permission.sensors: sensorsStatus,
          Permission.camera: cameraStatus,
          Permission.notification: notifStatus,
          Permission.photos: photoStatus,
        };
      });
    }
  }

  Future<void> _sendTestNotification(AppLocalizations l10n) async {
    await _notificationService.showImmediateNotification(
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
    );
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leadingWidth: 70,
                  leading: const AppBackButton(),
                  centerTitle: true,
                  title: Text(
                    l10n.notificationSettings,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader(l10n.permissionsStatus),
                      const SizedBox(height: 12),
                      _buildPermissionCard(
                        icon: Icons.notifications_active_rounded,
                        title: l10n.notifications,
                        permission: Permission.notification,
                        color: AppTheme.appBlue,
                      ),
                      _buildPermissionCard(
                        icon: Icons.camera_alt_rounded,
                        title: l10n.camera,
                        permission: Permission.camera,
                        color: AppTheme.appYellow,
                      ),
                      _buildPermissionCard(
                        icon: Icons.photo_library_rounded,
                        title: l10n.storage,
                        permission: Permission.photos,
                        color: AppTheme.appGreen,
                      ),
                      _buildPermissionCard(
                        icon: Icons.directions_run_rounded,
                        title: isAr ? "النشاط البدني" : "Activity Tracking",
                        permission: Permission.activityRecognition,
                        color: Colors.orange,
                      ),
                      _buildPermissionCard(
                        icon: Icons.monitor_heart_rounded,
                        title: isAr ? "حساسات الجسم" : "Body Sensors",
                        permission: Permission.sensors,
                        color: AppTheme.appRed,
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader(l10n.notificationSettings),
                      const SizedBox(height: 12),

                      GlassCard(
                        child: Column(
                          children: [
                            _buildToggleRow(
                              title: l10n.allowAllNotifications,
                              value: _allNotifications,
                              onChanged: (val) {
                                setState(() {
                                  _allNotifications = val;
                                  if (!val) {
                                    _streakNotifications = false;
                                    _taskNotifications = false;
                                    _insightsNotifications = false;
                                  } else {
                                    _streakNotifications = true;
                                    _taskNotifications = true;
                                    _insightsNotifications = true;
                                  }
                                });
                                _saveSettings();
                              },
                              icon: Icons.notifications_none_rounded,
                              iconColor: AppTheme.appBlue,
                            ),
                            const Divider(height: 1, indent: 50),
                            _buildToggleRow(
                              title: l10n.enableSounds,
                              value: _soundsEnabled,
                              onChanged: (val) {
                                setState(() => _soundsEnabled = val);
                                _saveSettings();
                              },
                              icon: Icons.volume_up_rounded,
                              iconColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        isAr ? "تخصيص الإشعارات" : "Customize Alerts",
                      ),
                      const SizedBox(height: 12),

                      GlassCard(
                        child: Column(
                          children: [
                            _buildToggleRow(
                              title: l10n.streakNotifications,
                              value: _streakNotifications,
                              enabled: _allNotifications,
                              onChanged: (val) {
                                setState(() => _streakNotifications = val);
                                _saveSettings();
                              },
                              icon: Icons.local_fire_department_rounded,
                              iconColor: AppTheme.appRed,
                            ),
                            const Divider(height: 1, indent: 50),
                            _buildToggleRow(
                              title: l10n.taskNotifications,
                              value: _taskNotifications,
                              enabled: _allNotifications,
                              onChanged: (val) {
                                setState(() => _taskNotifications = val);
                                _saveSettings();
                              },
                              icon: Icons.task_alt_rounded,
                              iconColor: AppTheme.appGreen,
                            ),
                            const Divider(height: 1, indent: 50),
                            _buildToggleRow(
                              title: l10n.insightsNotifications,
                              value: _insightsNotifications,
                              enabled: _allNotifications,
                              onChanged: (val) {
                                setState(() => _insightsNotifications = val);
                                _saveSettings();
                              },
                              icon: Icons.lightbulb_outline_rounded,
                              iconColor: AppTheme.appYellow,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton.icon(
                          onPressed: () => _sendTestNotification(l10n),
                          icon: const Icon(Icons.send_rounded),
                          label: Text(l10n.testNotification),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.appBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.appBlue.withOpacity(0.4),
                          ),
                        ),
                      ).animate().scale(
                        delay: 400.ms,
                        curve: Curves.bounceInOut,
                      ),

                      const SizedBox(height: 60),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required Permission permission,
    required Color color,
  }) {
    final status = _permissionStatuses[permission] ?? PermissionStatus.denied;
    final isGranted = status.isGranted;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      isGranted ? l10n.granted : l10n.denied,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isGranted ? AppTheme.appGreen : AppTheme.appRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGranted)
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  child: Text(
                    l10n.openSettings,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.appBlue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color iconColor,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? const Color(0xFF1E293B) : Colors.grey,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.appBlue,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
