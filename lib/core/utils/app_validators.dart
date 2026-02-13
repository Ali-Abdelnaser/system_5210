import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class AppValidators {
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    if (value.trim().length < 6) {
      return AppLocalizations.of(context)!.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    BuildContext context,
  ) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    if (value != password) {
      return AppLocalizations.of(context)!.passwordsDoNotMatch;
    }
    return null;
  }

  static String? validateName(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.nameRequired;
    }
    return null;
  }

  static String? validateRequired(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  static String? validatePhone(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.phoneRequired;
    }
    if (value.trim().length < 10) {
      return AppLocalizations.of(context)!.invalidPhone;
    }
    return null;
  }
}
