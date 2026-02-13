import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../auth/presentation/widgets/auth_gradient_button.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../core/utils/app_images.dart';
import '../../presentation/manager/user_setup_cubit.dart';
import '../widgets/profile_child_card.dart';
import '../widgets/add_child_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_alerts.dart';

class ParentProfileSetupView extends StatefulWidget {
  const ParentProfileSetupView({super.key});

  @override
  State<ParentProfileSetupView> createState() => _ParentProfileSetupViewState();
}

class _ParentProfileSetupViewState extends State<ParentProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedPriority;
  final List<Map<String, dynamic>> _children = [];
  String _relationship = 'Mother';
  bool _isRelationshipExpanded = false;
  bool _isPriorityExpanded = false;

  void _addChild(Map<String, dynamic> childData) {
    setState(() {
      _children.add(childData);
    });
  }

  void _deleteChild(int index) {
    setState(() {
      _children.removeAt(index);
    });
  }

  void _updateChild(int index, Map<String, dynamic> updatedData) {
    setState(() {
      _children[index] = updatedData;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showAddChildSheet({int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddChildBottomSheet(
        initialData: index != null ? _children[index] : null,
        onSave: (data) {
          if (index != null) {
            _updateChild(index, data);
          } else {
            _addChild(data);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<UserSetupCubit, UserSetupState>(
      listener: (context, state) {
        if (state is UserSetupSuccess) {
          Navigator.pushReplacementNamed(context, AppRoutes.congratulations);
        } else if (state is UserSetupFailure) {
          AppAlerts.showAlert(
            context,
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 50,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          l10n.completeProfile,
                          style: GoogleFonts.dynaPuff(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          l10n.setupDesc,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Parent Info Section
                      _buildSectionHeader(l10n.yourInfo, AppImages.iconParent),
                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _nameController,
                        label: l10n.fullName,
                        iconPath: AppImages.iconUser,
                        validator: (value) =>
                            AppValidators.validateName(value, context),
                      ),
                      const SizedBox(height: 16),

                      _buildModernLabel(l10n.relationship),
                      const SizedBox(height: 10),
                      _buildChicGlassDropdown(
                        label: "Select ${l10n.relationship}",
                        value: _relationship,
                        items: [
                          {'val': 'Mother', 'label': l10n.mother},
                          {'val': 'Father', 'label': l10n.father},
                          {'val': 'Guardian', 'label': l10n.guardian},
                        ],
                        onSelect: (v) => setState(() {
                          _relationship = v;
                          _isRelationshipExpanded = false;
                        }),
                        iconPath: AppImages.iconUser,
                        isExpanded: _isRelationshipExpanded,
                        onToggle: () => setState(() {
                          _isRelationshipExpanded = !_isRelationshipExpanded;
                          _isPriorityExpanded = false;
                        }),
                      ),

                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _cityController,
                        label: l10n.city,
                        iconPath: AppImages.iconLocation,
                        validator: (value) =>
                            AppValidators.validateRequired(value, context),
                      ),
                      const SizedBox(height: 24),
                      _buildModernLabel(l10n.familyPriority),
                      const SizedBox(height: 10),
                      _buildChicGlassDropdown(
                        label: "Select Priority",
                        value: _selectedPriority,
                        items: [
                          {'val': "Healthy Eating", 'label': "Healthy Eating"},
                          {
                            'val': "Physical Activity",
                            'label': "Physical Activity",
                          },
                          {
                            'val': "Reduced Screen Time",
                            'label': "Reduced Screen Time",
                          },
                          {'val': "Zero Soda", 'label': "Zero Soda"},
                        ],
                        onSelect: (v) => setState(() {
                          _selectedPriority = v;
                          _isPriorityExpanded = false;
                        }),
                        iconPath: AppImages.iconFamily,
                        isExpanded: _isPriorityExpanded,
                        onToggle: () => setState(() {
                          _isPriorityExpanded = !_isPriorityExpanded;
                          _isRelationshipExpanded = false;
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Children Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(
                            l10n.yourChildren(_children.length),
                            AppImages.iconChild,
                          ),
                          TextButton.icon(
                            onPressed: _showAddChildSheet,
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 20,
                            ),
                            label: Text(
                              l10n.addChild,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (_children.isEmpty)
                        _buildEmptyChildrenState(l10n)
                      else
                        ..._children.asMap().entries.map((entry) {
                          final index = entry.key;
                          final child = entry.value;
                          return ProfileChildCard(
                            child: child,
                            onDelete: () => _deleteChild(index),
                            onEdit: () => _showAddChildSheet(index: index),
                          );
                        }),

                      const SizedBox(height: 48),

                      BlocBuilder<UserSetupCubit, UserSetupState>(
                        builder: (context, state) {
                          return AuthGradientButton(
                            text: l10n.finishSetup,
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                if (_children.isEmpty) {
                                  AppAlerts.showAlert(
                                    context,
                                    message: l10n.addChildError,
                                    type: AlertType.warning,
                                  );
                                  return;
                                }
                                // 1. Prepare Parent Data
                                final parentData = {
                                  'fullName': _nameController.text,
                                  'relationship': _relationship,
                                  'city': _cityController.text,
                                  'priority': _selectedPriority,
                                  'children': _children,
                                };

                                // 2. Update Cubit
                                final cubit = context.read<UserSetupCubit>();
                                cubit.updateParentProfile(parentData);

                                // 3. Submit
                                cubit.submitSetup();
                              }
                            },
                            colors: const [AppTheme.appRed, AppTheme.appRed],
                            isLoading: state is UserSetupLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String iconPath) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 35,
          height: 35,
          colorFilter: const ColorFilter.mode(
            Color(0xFF1565C0),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildModernLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildChicGlassDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String) onSelect,
    required String iconPath,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFF1565C0).withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1565C0),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        value ?? "Choose One...",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: value == null
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: items.map((item) {
                    final isSelected = value == item['val'];
                    return InkWell(
                      onTap: () => onSelect(item['val']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0).withOpacity(0.1)
                              : Colors.transparent,
                          border: items.last == item
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyChildrenState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppImages.iconChild,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noChildrenAdded,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
