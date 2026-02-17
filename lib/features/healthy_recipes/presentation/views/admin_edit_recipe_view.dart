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
import 'package:system_5210/features/healthy_recipes/data/models/recipe_model.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/image_compressor.dart';

class AdminEditRecipeView extends StatefulWidget {
  final RecipeModel? recipe;
  const AdminEditRecipeView({super.key, this.recipe});

  @override
  State<AdminEditRecipeView> createState() => _AdminEditRecipeViewState();
}

class _AdminEditRecipeViewState extends State<AdminEditRecipeView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameAr,
      _nameEn,
      _ingredientsAr,
      _ingredientsEn,
      _stepsAr,
      _stepsEn,
      _videoUrl;

  File? _imageFile;
  String? _existingImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.recipe?.imageUrl;
    _nameAr = TextEditingController(text: widget.recipe?.nameAr);
    _nameEn = TextEditingController(text: widget.recipe?.nameEn);
    _ingredientsAr = TextEditingController(
      text: widget.recipe?.ingredientsAr.join('\n'),
    );
    _ingredientsEn = TextEditingController(
      text: widget.recipe?.ingredientsEn.join('\n'),
    );
    _stepsAr = TextEditingController(text: widget.recipe?.stepsAr.join('\n'));
    _stepsEn = TextEditingController(text: widget.recipe?.stepsEn.join('\n'));
    _videoUrl = TextEditingController(text: widget.recipe?.videoUrl);
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
        final compressedFile = await ImageCompressor.compressToWebP(
          _imageFile!,
        );
        final fileToUpload = compressedFile ?? _imageFile!;

        final ref = FirebaseStorage.instance.ref().child(
          'recipes/${DateTime.now().millisecondsSinceEpoch}.webp',
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
        'ingredientsAr': _ingredientsAr.text
            .trim()
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        'ingredientsEn': _ingredientsEn.text
            .trim()
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        'stepsAr': _stepsAr.text
            .trim()
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        'stepsEn': _stepsEn.text
            .trim()
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        'videoUrl': _videoUrl.text.trim(),
        'imageUrl': imageUrl,
      };

      if (widget.recipe == null) {
        await FirebaseFirestore.instance
            .collection('healthy_recipes')
            .add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('healthy_recipes')
            .doc(widget.recipe!.id)
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
          widget.recipe == null ? l10n.adminAddRecipe : l10n.adminEditRecipe,
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
                          _buildTextArea(
                            _ingredientsAr,
                            l10n.adminRecipeIngredientsAr,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          _buildTextArea(
                            _ingredientsEn,
                            l10n.adminRecipeIngredientsEn,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          _buildTextArea(
                            _stepsAr,
                            l10n.adminRecipeStepsAr,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          _buildTextArea(
                            _stepsEn,
                            l10n.adminRecipeStepsEn,
                            textColor,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _videoUrl,
                            label: l10n.adminRecipeVideoUrl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSaveButton(l10n),
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
                    l10n.adminRecipePhoto,
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

  Widget _buildTextArea(
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
            maxLines: 5,
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

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.appBlue, Color(0xFF4A90E2)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: AppTheme.appBlue.withOpacity(0.3), blurRadius: 10),
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
    );
  }
}
