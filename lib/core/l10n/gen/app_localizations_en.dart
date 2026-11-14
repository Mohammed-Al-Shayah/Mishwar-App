// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mishwar';

  @override
  String get roleTitle => 'How do you want to use Mishwar?';

  @override
  String get roleRider => 'I need a ride';

  @override
  String get roleRiderSubtitle => 'Get a car wherever you\'re going';

  @override
  String get roleDriver => 'I want to drive';

  @override
  String get roleDriverSubtitle => 'Earn on your schedule';

  @override
  String get riderMode => 'Rider mode';

  @override
  String get driverMode => 'Driver mode';

  @override
  String get continueLabel => 'Continue';

  @override
  String get phoneTitle => 'Enter your mobile number';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get countryCode => '🇯🇴 +962';

  @override
  String get smsFootnote => 'We’ll send you an SMS with a verification code.';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSent(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get editPhone => 'Edit number';

  @override
  String get nameTitle => 'What’s your name?';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get signOutLabel => 'Sign out';

  @override
  String get retryLabel => 'Try again';

  @override
  String otpDigit(int digit) {
    return 'Code digit $digit';
  }

  @override
  String get errorInvalidPhone => 'Enter a valid mobile number.';

  @override
  String get errorInvalidCode => 'The code is incorrect. Try again.';

  @override
  String get errorCodeExpired => 'The code expired. Request a new code.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorNetwork => 'Check your internet connection and try again.';

  @override
  String get errorQuota =>
      'SMS is temporarily unavailable. Please try again later.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNameRequired => 'Enter your first and last name.';

  @override
  String get errorNameLength =>
      'Your name must be between 2 and 40 characters.';
}
