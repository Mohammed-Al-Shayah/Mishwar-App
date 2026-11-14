// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مشوار';

  @override
  String get roleTitle => 'كيف بدك تستخدم مشوار؟';

  @override
  String get roleRider => 'بدي أطلب مشوار';

  @override
  String get roleRiderSubtitle => 'اطلب سيارة لوين ما بدك';

  @override
  String get roleDriver => 'بدي أشتغل سائق';

  @override
  String get roleDriverSubtitle => 'اكسب على وقتك';

  @override
  String get riderMode => 'وضع الراكب';

  @override
  String get driverMode => 'وضع السائق';

  @override
  String get continueLabel => 'متابعة';
}
