import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_strings.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  final LocalStorageService localStorageService;
  final FirebaseFirestore firestore;

  UpdateService(this.localStorageService, this.firestore);

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Get current version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Get remote config from Firestore
      final doc = await firestore
          .collection('app_config')
          .doc('update_settings')
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final latestVersion = data['latestVersion'] as String? ?? '1.0.0';
      final minRequiredVersion =
          data['minRequiredVersion'] as String? ?? '1.0.0';
      final updateUrl = data['updateUrl'] as String? ?? AppStrings.storeUrl;

      // 3. Compare versions
      if (_isUpdateRequired(currentVersion, minRequiredVersion)) {
        // Force Update
        if (context.mounted) {
          _showUpdateDialog(context, updateUrl, isForce: true);
        }
      } else if (_isUpdateAvailable(currentVersion, latestVersion)) {
        // Flexible Update - check if already shown today
        if (await _shouldShowUpdatePrompt()) {
          if (context.mounted) {
            _showUpdateDialog(context, updateUrl, isForce: false);
          }
        }
      }
    } catch (e) {
      debugPrint("Update check error: $e");
    }
  }

  bool _isUpdateRequired(String current, String minRequired) {
    return _compareVersions(current, minRequired) < 0;
  }

  bool _isUpdateAvailable(String current, String latest) {
    return _compareVersions(current, latest) < 0;
  }

  int _compareVersions(String v1, String v2) {
    List<int> v1List = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2List = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros if needed
    while (v1List.length < 3) v1List.add(0);
    while (v2List.length < 3) v2List.add(0);

    for (int i = 0; i < 3; i++) {
      if (v1List[i] < v2List[i]) return -1;
      if (v1List[i] > v2List[i]) return 1;
    }
    return 0;
  }

  Future<bool> _shouldShowUpdatePrompt() async {
    final data = await localStorageService.get(
      'app_updates',
      'last_prompt_date',
    );
    if (data == null || data['date'] == null) return true;

    try {
      final lastDate = DateTime.parse(data['date'] as String);
      final now = DateTime.now();
      // Only show after 24 hours
      return now.difference(lastDate).inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  Future<void> _recordPromptSkipped() async {
    await localStorageService.save('app_updates', 'last_prompt_date', {
      'date': DateTime.now().toIso8601String(),
    });
  }

  void _showUpdateDialog(
    BuildContext context,
    String url, {
    required bool isForce,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) => PopScope(
        canPop: !isForce,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: GlassContainer(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              opacity: 0.9,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isForce
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isForce
                          ? Icons.system_update_rounded
                          : Icons.rocket_launch_rounded,
                      size: 48,
                      color: isForce ? Colors.red : AppTheme.appBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isForce ? l10n.updateRequired : l10n.updateAvailable,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.updateDesc,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 15,
                      color: const Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _launchURL(url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.updateButton,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  if (!isForce) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _recordPromptSkipped();
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.laterButton,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }
}
