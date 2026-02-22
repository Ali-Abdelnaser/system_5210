import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';

class AdminNotificationControlView extends StatefulWidget {
  const AdminNotificationControlView({super.key});

  @override
  State<AdminNotificationControlView> createState() =>
      _AdminNotificationControlViewState();
}

class _AdminNotificationControlViewState
    extends State<AdminNotificationControlView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _actionUrlController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(String id) async {
    if (_selectedImage == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('notifications')
          .child('$id.webp');

      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }

  Future<void> _sendNotification() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      AppAlerts.showAlert(
        context,
        message: isAr
            ? 'الرجاء إدخال العنوان والمحتوى'
            : 'Please enter title and content',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String notificationId = DateTime.now().millisecondsSinceEpoch
          .toString();
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImage(notificationId);
      }

      final content = _titleController.text.trim();
      final bodyText = _bodyController.text.trim();

      await FirebaseFirestore.instance
          .collection('broadcast_notifications')
          .doc(notificationId)
          .set({
            'titleAr': content,
            'bodyAr': bodyText,
            'titleEn': content,
            'bodyEn': bodyText,
            'imageUrl': imageUrl,
            'actionUrl': _actionUrlController.text.trim().isEmpty
                ? null
                : _actionUrlController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'broadcast',
          });

      if (mounted) {
        AppAlerts.showCustomDialog(
          context,
          title: isAr ? 'تم الإرسال بنجاح' : 'Sent Successfully',
          message: isAr
              ? 'تم إرسال التنبيه وبثه لجميع المستخدمين بنجاح.'
              : 'The notification has been sent and broadcasted to all users.',
          buttonText: isAr ? 'تم' : 'Done',
          isSuccess: true,
          onPressed: () {
            Navigator.pop(context); // Close dialog
            _titleController.clear();
            _bodyController.clear();
            _actionUrlController.clear();
            setState(() => _selectedImage = null);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showAlert(
          context,
          message: isAr ? 'خطأ في الإرسال: $e' : 'Send error: $e',
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isAr ? 'إرسال تنبيه للكل' : 'Broadcast Notification',
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Redesigned Image Picker Section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (_selectedImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.appBlue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.appBlue.withOpacity(
                                          0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 45,
                                      color: AppTheme.appBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    isAr
                                        ? 'إضافة صورة جذابة للإشعار'
                                        : 'Add an Eye-Catching Image',
                                    style:
                                        (isAr
                                        ? GoogleFonts.cairo
                                        : GoogleFonts.poppins)(
                                          color: AppTheme.appBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    isAr
                                        ? 'اختياري ولكن يُنصح به'
                                        : 'Optional but recommended',
                                    style:
                                        (isAr
                                        ? GoogleFonts.cairo
                                        : GoogleFonts.poppins)(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          if (_selectedImage != null)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.appBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Content Section
                  _buildSectionHeader(
                    isAr ? 'محتوى الإشعار' : 'Notification Content',
                    textColor,
                    isAr,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    opacity: 0.1,
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _titleController,
                          label: isAr ? 'عنوان الإشعار' : 'Notification Title',
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          controller: _bodyController,
                          label: isAr ? 'محتوى الإشعار' : 'Notification Body',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Link Section
                  _buildSectionHeader(
                    isAr ? 'رابط خارجي (اختياري)' : 'External Link (Optional)',
                    textColor,
                    isAr,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    opacity: 0.1,
                    child: AuthTextField(
                      controller: _actionUrlController,
                      label: isAr
                          ? 'الرابط (مثال: https://...)'
                          : 'URL (e.g. https://...)',
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.appBlue, Color(0xFF4A90E2)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.appBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendNotification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const AppLoadingIndicator(size: 24)
                            : Text(
                                isAr ? 'إرسال الآن للكل' : 'Send Now to All',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, bool isAr) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.appBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
