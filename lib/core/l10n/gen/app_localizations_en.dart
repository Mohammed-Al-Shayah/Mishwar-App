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
}
