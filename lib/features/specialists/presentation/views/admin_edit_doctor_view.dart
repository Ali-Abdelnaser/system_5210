import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/features/specialists/data/models/doctor_model.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/image_compressor.dart';

class AdminEditDoctorView extends StatefulWidget {
  final DoctorModel? doctor;
  const AdminEditDoctorView({super.key, this.doctor});

  @override
  State<AdminEditDoctorView> createState() => _AdminEditDoctorViewState();
}

class _AdminEditDoctorViewState extends State<AdminEditDoctorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameAr,
      _nameEn,
      _specAr,
      _specEn,
      _aboutAr,
      _aboutEn,
      _location,
      _contact,
      _whatsapp,
      _experience,
      _hoursAr,
      _hoursEn,
      _daysAr,
      _daysEn;
  bool _allowsOnline = false;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.doctor?.imageUrl;
    _allowsOnline = widget.doctor?.allowsOnlineConsultation ?? false;
    _nameAr = TextEditingController(text: widget.doctor?.nameAr);
    _nameEn = TextEditingController(text: widget.doctor?.nameEn);
    _specAr = TextEditingController(text: widget.doctor?.specialtyAr);
    _specEn = TextEditingController(text: widget.doctor?.specialtyEn);
    _aboutAr = TextEditingController(text: widget.doctor?.aboutAr);
    _aboutEn = TextEditingController(text: widget.doctor?.aboutEn);
    _location = TextEditingController(text: widget.doctor?.clinicLocation);
    _contact = TextEditingController(text: widget.doctor?.contactNumber);
    _whatsapp = TextEditingController(text: widget.doctor?.whatsappNumber);
    _experience = TextEditingController(
      text: widget.doctor?.experienceYears.toString(),
    );
    _hoursAr = TextEditingController(text: widget.doctor?.workingHoursAr);
    _hoursEn = TextEditingController(text: widget.doctor?.workingHoursEn);
    _daysAr = TextEditingController(
      text: widget.doctor?.workingDaysAr.join(', '),
    );
    _daysEn = TextEditingController(
      text: widget.doctor?.workingDaysEn.join(', '),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_imageFile != null) {
        // Compress to WebP
        final compressedFile = await ImageCompressor.compressToWebP(
          _imageFile!,
        );
        final fileToUpload = compressedFile ?? _imageFile!;

        final ref = FirebaseStorage.instance.ref().child(
          'doctors/${DateTime.now().millisecondsSinceEpoch}.webp',
        );
        await ref.putFile(
          fileToUpload,
          SettableMetadata(contentType: 'image/webp'),
        );
        imageUrl = await ref.getDownloadURL();
      }

      final data = {
        'nameAr': _nameAr.text.trim(),
        'nameEn': _nameEn.text.trim(),
        'specialtyAr': _specAr.text.trim(),
        'specialtyEn': _specEn.text.trim(),
        'aboutAr': _aboutAr.text.trim(),
        'aboutEn': _aboutEn.text.trim(),
        'imageUrl': imageUrl,
        'clinicLocation': _location.text.trim(),
        'allowsOnlineConsultation': _allowsOnline,
        'contactNumber': _contact.text.trim(),
        'whatsappNumber': _whatsapp.text.trim(),
        'experienceYears': int.tryParse(_experience.text) ?? 0,
        'workingHoursAr': _hoursAr.text.trim(),
        'workingHoursEn': _hoursEn.text.trim(),
        'workingDaysAr': _daysAr.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'workingDaysEn': _daysEn.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'certificates': widget.doctor?.certificates ?? [],
      };

      if (widget.doctor == null) {
        await FirebaseFirestore.instance.collection('specialists').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('specialists')
            .doc(widget.doctor!.id)
            .update(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.doctor == null ? l10n.adminAddDoctor : l10n.adminEditDoctor,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePicker(l10n, textColor),
                    const SizedBox(height: 32),
                    GlassContainer(
                      padding: const EdgeInsets.all(25),
                      borderRadius: BorderRadius.circular(35),
                      opacity: 0.1,
                      blur: 25,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _nameAr,
                            label: l10n.adminNameAr,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _nameEn,
                            label: l10n.adminNameEn,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _specAr,
                            label: l10n.adminSpecialtyAr,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _specEn,
                            label: l10n.adminSpecialtyEn,
                          ),
                          const SizedBox(height: 20),
                          _buildAboutField(
                            _aboutAr,
                            l10n.adminAboutAr,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          _buildAboutField(
                            _aboutEn,
                            l10n.adminAboutEn,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _location,
                            label: l10n.adminClinicLocation,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _contact,
                            label: l10n.adminContactNumber,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _whatsapp,
                            label: l10n.adminWhatsappNumber,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _experience,
                            label: l10n.adminExperienceYears,
                            isNumeric: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AuthTextField(
                                  controller: _hoursAr,
                                  label: l10n.adminWorkingHoursAr,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthTextField(
                                  controller: _hoursEn,
                                  label: l10n.adminWorkingHoursEn,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AuthTextField(
                                  controller: _daysAr,
                                  label: l10n.adminWorkingDaysAr,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthTextField(
                                  controller: _daysEn,
                                  label: l10n.adminWorkingDaysEn,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.adminOnlineConsultation,
                              style: GoogleFonts.cairo(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            value: _allowsOnline,
                            activeColor: AppTheme.appBlue,
                            onChanged: (v) => setState(() => _allowsOnline = v),
                          ),
                        ],
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
                              color: AppTheme.appBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isSaving
                              ? const AppLoadingIndicator(size: 24)
                              : Text(
                                  l10n.adminSaveData,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n, Color textColor) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          image: _imageFile != null
              ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
              : (_existingImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_existingImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null),
        ),
        child: _imageFile == null && _existingImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 40,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.adminDoctorPhoto,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildAboutField(
    TextEditingController controller,
    String label,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F5E7B),
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF1E293B),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (v) => v!.isEmpty ? 'Field required' : null,
          ),
        ),
      ],
    );
  }
}
