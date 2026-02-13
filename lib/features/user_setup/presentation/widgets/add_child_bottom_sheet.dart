import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/utils/app_images.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:system_5210/core/utils/app_validators.dart';

class AddChildBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const AddChildBottomSheet({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<AddChildBottomSheet> createState() => _AddChildBottomSheetState();
}

class _AddChildBottomSheetState extends State<AddChildBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _heroController;
  late final TextEditingController _notesController;
  late final TextEditingController _diseaseDetailsController;

  String _gender = 'Boy';
  bool _hasDisease = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _ageController = TextEditingController(text: data?['age'] ?? '');
    _weightController = TextEditingController(text: data?['weight'] ?? '');
    _heightController = TextEditingController(text: data?['height'] ?? '');
    _heroController = TextEditingController(text: data?['favoriteHero'] ?? '');
    _notesController = TextEditingController(text: data?['notes'] ?? '');
    _diseaseDetailsController = TextEditingController(
      text: data?['diseaseDetails'] ?? '',
    );
    _gender = data?['gender'] ?? 'Boy';
    _hasDisease = data?['disease'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _heroController.dispose();
    _notesController.dispose();
    _diseaseDetailsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'name': _nameController.text,
        'age': _ageController.text,
        'weight': _weightController.text,
        'height': _heightController.text,
        'favoriteHero': _heroController.text,
        'gender': _gender,
        'disease': _hasDisease,
        'diseaseDetails': _hasDisease ? _diseaseDetailsController.text : null,
        'notes': _notesController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initialData != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child:
              Column(
                    children: [
                      // Handle Bar
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Header Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SvgPicture.asset(
                                AppImages.iconChild,
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF1565C0),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isEditing ? l10n.completeProfile : l10n.addChild,
                              style: GoogleFonts.dynaPuff(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                        color: Color.fromARGB(255, 163, 163, 163),
                      ),

                      // Scrollable Form Content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(24),
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AuthTextField(
                                    label: l10n.childName,
                                    iconPath: AppImages.iconUser,
                                    controller: _nameController,
                                    validator: (value) =>
                                        AppValidators.validateName(
                                          value,
                                          context,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AuthTextField(
                                          label: l10n.childAge,
                                          iconPath: AppImages.iconChild,
                                          isNumeric: true,
                                          controller: _ageController,
                                          validator: (value) =>
                                              AppValidators.validateRequired(
                                                value,
                                                context,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel(l10n.gender),
                                            _buildGenderToggle(l10n),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AuthTextField(
                                          label: l10n.weight,
                                          iconPath: AppImages.iconWeight,
                                          isNumeric: true,
                                          controller: _weightController,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: AuthTextField(
                                          label: l10n.height,
                                          iconPath: AppImages.iconHeight,
                                          isNumeric: true,
                                          controller: _heightController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    label: l10n.favoriteHero,
                                    iconPath: AppImages.iconUser,
                                    controller: _heroController,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildDiseaseSection(l10n),
                            const SizedBox(height: 20),

                            _buildLabel(l10n.notesHabits),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: l10n.notesHint,
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            AuthGradientButton(
                              text: isEditing
                                  ? l10n.finishSetup
                                  : l10n.saveChild,
                              onTap: _save,
                              colors: const [
                                Color(0xFF1565C0),
                                Color(0xFF0D47A1),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildGenderToggle(AppLocalizations l10n) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildGenderBtn(l10n.boy, 'Boy')),
          Expanded(child: _buildGenderBtn(l10n.girl, 'Girl')),
        ],
      ),
    );
  }

  Widget _buildGenderBtn(String label, String value) {
    final isSelected = _gender == value;
    final color = value == 'Boy' ? Colors.blue : Colors.pink;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? color : Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.chronicDiseases,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF334155),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 30,
                child: Switch(
                  value: _hasDisease,
                  activeColor: const Color(0xFF1565C0),
                  onChanged: (v) => setState(() => _hasDisease = v),
                ),
              ),
            ],
          ),
          if (_hasDisease) ...[
            const Divider(height: 24),
            TextField(
              controller: _diseaseDetailsController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.specifyDetails,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
