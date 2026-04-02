import 'package:flutter/widgets.dart';
import 'package:five2ten/l10n/app_localizations.dart';

/// Maps backend/cubit English messages and internal keys to [AppLocalizations].
String localizeAuthMessage(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return message;

  switch (message) {
    case '##AUTH_SIGN_IN_INSTEAD':
      return l10n.authSignInInstead;
    case '##AUTH_WRONG_PASSWORD':
      return l10n.authWrongPasswordExistingEmail;
    case 'No internet connection. Please check your network and try again.':
      return l10n.authNoInternetConnection;
    case 'This phone number is not registered. Please create an account first.':
      return l10n.authPhoneNotRegistered;
    case 'This phone number is already registered. Please sign in instead.':
      return l10n.authPhoneAlreadyRegisteredSignIn;
    case 'This email is not registered. Please create an account first.':
      return l10n.authEmailNotRegistered;
    case 'Email not verified yet. Please check your inbox.':
      return l10n.authEmailNotVerifiedYet;
    case 'Session expired. Please login again.':
    case 'Session expired.':
      return l10n.authSessionExpired;
    case 'Please enter 6 digits':
      return l10n.authEnterSixDigits;
    case 'Wrong password. Please try again.':
      return l10n.authWrongPasswordTryAgain;
    case 'Invalid email address.':
      return l10n.authInvalidEmailAddress;
    case 'No account found with this email.':
      return l10n.authNoAccountFoundEmail;
    case 'An account already exists with this email.':
      return l10n.authEmailAlreadyExistsGeneric;
    case 'Invalid verification code.':
      return l10n.authInvalidVerificationCode;
    case 'Access from this device has been temporarily blocked due to unusual activity. Please try again later.':
      return l10n.authTooManyRequests;
    default:
      return message;
  }
}
