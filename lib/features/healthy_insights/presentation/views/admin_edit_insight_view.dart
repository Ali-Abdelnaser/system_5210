import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/healthy_insights/domain/entities/healthy_insight.dart';

class AdminEditInsightView extends StatefulWidget {
  final HealthyInsight? insight;
  const AdminEditInsightView({super.key, this.insight});

  @override
  State<AdminEditInsightView> createState() => _AdminEditInsightViewState();
}

class _AdminEditInsightViewState extends State<AdminEditInsightView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _sourceNameController;
  late TextEditingController _sourceLinkController;
  String _selectedCategory = 'الصحة العامة';
  bool _isLoading = false;

  final List<String> _categories = [
    'السمنة',
    'التغذية',
    'الصحة الرقمية',
    'النشاط البدني',
    'الصحة العامة',
  ];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.insight?.question);
    _answerController = TextEditingController(text: widget.insight?.answer);
    _sourceNameController = TextEditingController(
      text: widget.insight?.sourceName,
    );
    _sourceLinkController = TextEditingController(
      text: widget.insight?.sourceLink,
    );
    if (widget.insight != null) {
      _selectedCategory = widget.insight!.category;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _sourceNameController.dispose();
    _sourceLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveInsight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final insightData = {
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
        'sourceName': _sourceNameController.text.trim(),
        'sourceLink': _sourceLinkController.text.trim(),
        'category': _selectedCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.insight == null) {
        await FirebaseFirestore.instance
            .collection('healthy_insights')
            .add(insightData);
      } else {
        await FirebaseFirestore.instance
            .collection('healthy_insights')
            .doc(widget.insight!.id)
            .update(insightData);
      }

      if (mounted) {
        AppAlerts.showAlert(
          context,
          message: widget.insight == null
              ? 'تمت الإضافة بنجاح'
              : 'تم التحديث بنجاح',
          type: AlertType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showAlert(context, message: 'خطأ: $e', type: AlertType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.insight == null ? 'إضافة معلومة' : 'تعديل معلومة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const AppBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('السؤال'),
              _buildTextField(
                controller: _questionController,
                hint: 'أدخل السؤال هنا...',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              _buildLabel('التصنيف'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.cairo()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _selectedCategory = newValue!);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('الإجابة'),
              _buildTextField(
                controller: _answerController,
                hint: 'أدخل الإجابة بالتفصيل...',
                maxLines: 6,
              ),
              const SizedBox(height: 20),

              _buildLabel('المصدر (الاسم)'),
              _buildTextField(
                controller: _sourceNameController,
                hint: 'مثال: منظمة الصحة العالمية',
              ),
              const SizedBox(height: 20),

              _buildLabel('رابط المصدر'),
              _buildTextField(
                controller: _sourceLinkController,
                hint: 'https://...',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveInsight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.insight == null
                              ? 'إضافة المعلومة'
                              : 'حفظ التعديلات',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.cairo(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.appBlue, width: 2),
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }
}
