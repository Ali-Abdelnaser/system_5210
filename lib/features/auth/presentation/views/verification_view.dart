import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_state.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_header.dart';
import 'package:system_5210/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/utils/app_utils.dart';

class VerificationView extends StatefulWidget {
  final bool isEmail;
  final String? email;
  final String? phoneNumber;
  final String? verificationId;
  final bool isPasswordReset;

  const VerificationView({
    super.key,
    required this.isEmail,
    this.email,
    this.phoneNumber,
    this.verificationId,
    this.isPasswordReset = false,
  });

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  /// Phone OTP: 6 digits. Email link: no boxes, just "Continue".
  late final bool _isPhoneVerification;
  late final int _codeLength;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late Timer _timer;
  int _start = 60;
  bool _canResend = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _isPhoneVerification = widget.verificationId != null;
    _codeLength =
        (_isPhoneVerification || widget.isPasswordReset || widget.isEmail)
        ? 6
        : 0;
    _controllers = _codeLength > 0
        ? List.generate(_codeLength, (_) => TextEditingController())
        : [];
    _focusNodes = _codeLength > 0
        ? List.generate(
            _codeLength,
            (index) => FocusNode(
              onKey: (node, event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  if (_controllers[index].text.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
            ),
          )
        : [];
    if (_isPhoneVerification) {
      startTimer();
    }
  }

  void startTimer() {
    _start = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }

    for (var node in _focusNodes) {
      node.dispose();
    }
    if (_isPhoneVerification) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);
    if (value.length > 1) {
      // Handling Paste: Distribute across fields
      final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanValue.isEmpty) {
        _controllers[index].clear();
        return;
      }

      // Fill controllers starting from current index
      for (int i = 0; i < cleanValue.length && (index + i) < _codeLength; i++) {
        _controllers[index + i].text = cleanValue[i];
      }

      // Move focus to the end of pasted content or last field
      int newFocusIndex = index + cleanValue.length;
      if (newFocusIndex >= _codeLength) newFocusIndex = _codeLength - 1;
      _focusNodes[newFocusIndex].requestFocus();
    } else if (value.isNotEmpty) {
      // Normal typing: move focus forward
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  void _onVerify(BuildContext context) async {
    if (!await AppUtils.checkInternet(context)) return;
    if (_isPhoneVerification) {
      final code = _controllers.map((c) => c.text).join();
      if (code.length != _codeLength) {
        setState(() => _hasError = true);
        AppAlerts.showAlert(context, message: "Please enter 6 digits");
        return;
      }
      context.read<AuthCubit>().verifyPhoneCode(
        verificationId: widget.verificationId!,
        smsCode: code,
      );
    } else if (widget.isPasswordReset) {
      final code = _controllers.map((c) => c.text).join();
      if (code.length != _codeLength) {
        setState(() => _hasError = true);
        AppAlerts.showAlert(context, message: "Please enter 6 digits");
        return;
      }
      // Verify OTP through Cubit
      context.read<AuthCubit>().verifyPasswordResetOTP(
        email: widget.email!,
        code: code,
      );
    } else if (widget.isEmail) {
      final code = _controllers.map((c) => c.text).join();
      if (code.length != _codeLength) {
        setState(() => _hasError = true);
        AppAlerts.showAlert(context, message: "Please enter 6 digits");
        return;
      }
      context.read<AuthCubit>().verifyEmailOTP(
        email: widget.email!,
        code: code,
      );
    } else {
      // Fallback or link check
      context.read<AuthCubit>().checkEmailVerificationStatus();
    }
  }

  void _showSuccessDialog(BuildContext context, AuthSuccess state) {
    final l10n = AppLocalizations.of(context)!;
    AppAlerts.showCustomDialog(
      context,
      title: l10n.verified,
      message: l10n.verifiedDesc,
      buttonText: l10n.continueButton,
      isSuccess: true,
      onPressed: () {
        Navigator.pop(context); // Close dialog
        if (state.dataExists) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _showSuccessDialog(context, state);
        } else if (state is AuthEmailVerificationVerified) {
          // Success dialog already shown or we can just wait for AuthSuccess which cubit emits after verification
        } else if (state is AuthPasswordResetVerified) {
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: widget.email,
          );
        } else if (state is AuthFailure) {
          AppAlerts.showAlert(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 50,
          leading: const AppBackButton(),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height,
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // App Logo (Matching Login/Register)
                    const SizedBox(height: 10),
                    AuthHeader(
                      title: widget.isPasswordReset
                          ? l10n.forgotPasswordTitle
                          : (widget.isEmail
                                ? l10n.verifyEmailTitle
                                : l10n.verifyPhoneTitle),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 10),
                    Text(
                      widget.isPasswordReset
                          ? l10n.forgotPasswordDesc
                          : (_isPhoneVerification
                                ? l10n.verifyPhoneDesc
                                : (widget.isEmail
                                      ? l10n.emailVerificationLinkSent
                                      : l10n.verifyPhoneDesc)),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    if (_codeLength > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _codeLength,
                          (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (value) =>
                                      _onChanged(index, value),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D3142),
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.redAccent
                                            : const Color(0xFFF1F5F9),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.redAccent
                                            : AppTheme.appRed,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 40),
                    ],

                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AuthGradientButton(
                          text: _isPhoneVerification
                              ? l10n.verify
                              : l10n.continueButton,
                          onTap: () => _onVerify(context),
                          colors: const [AppTheme.appRed, Color(0xFFFF6B6B)],
                          isLoading: state is AuthLoading,
                        );
                      },
                    ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),

                    if (_codeLength > 0) ...[
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: _canResend
                            ? () {
                                if (widget.isEmail) {
                                  if (widget.isPasswordReset) {
                                    context.read<AuthCubit>().forgotPassword(
                                      widget.email!,
                                    );
                                  } else {
                                    context
                                        .read<AuthCubit>()
                                        .sendEmailVerificationOTP(
                                          widget.email!,
                                        );
                                  }
                                } else if (_isPhoneVerification &&
                                    widget.phoneNumber != null) {
                                  context
                                      .read<AuthCubit>()
                                      .sendPhoneVerificationCode(
                                        widget.phoneNumber!,
                                      );
                                }
                                startTimer();
                                AppAlerts.showAlert(
                                  context,
                                  message: "Verification code resent!",
                                  type: AlertType.success,
                                );
                              }
                            : null,
                        child: Text(
                          _canResend
                              ? l10n.resendCode
                              : "${l10n.resendCode} ($_start)",
                          style: GoogleFonts.poppins(
                            color: _canResend ? AppTheme.appRed : Colors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                    const SizedBox(height: 500),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
