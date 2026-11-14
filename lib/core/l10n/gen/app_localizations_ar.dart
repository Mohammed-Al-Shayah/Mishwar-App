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

  @override
  String get phoneTitle => 'أدخل رقم موبايلك';

  @override
  String get phoneLabel => 'رقم الموبايل';

  @override
  String get countryCode => '🇯🇴 +962';

  @override
  String get smsFootnote => 'رح نبعتلك رسالة SMS فيها رمز التحقق.';

  @override
  String get otpTitle => 'أدخل الرمز';

  @override
  String otpSent(String phone) {
    return 'بعتنالك رمز على $phone';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCountdown(int seconds) {
    return 'إعادة الإرسال بعد $seconds ث';
  }

  @override
  String get editPhone => 'تعديل الرقم';

  @override
  String get nameTitle => 'شو اسمك؟';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get signOutLabel => 'تسجيل الخروج';

  @override
  String get retryLabel => 'حاول مرة ثانية';

  @override
  String otpDigit(int digit) {
    return 'خانة الرمز $digit';
  }

  @override
  String get errorInvalidPhone => 'أدخل رقم موبايل صحيح.';

  @override
  String get errorInvalidCode => 'الرمز مش صحيح. جرّب مرة ثانية.';

  @override
  String get errorCodeExpired => 'انتهت صلاحية الرمز. اطلب رمز جديد.';

  @override
  String get errorTooManyRequests => 'محاولات كثيرة. جرّب بعد شوي.';

  @override
  String get errorNetwork => 'تأكد من اتصال الإنترنت وجرّب مرة ثانية.';

  @override
  String get errorQuota => 'الرسائل مش متاحة حالياً. جرّب بعد شوي.';

  @override
  String get errorGeneric => 'صار خطأ. جرّب مرة ثانية.';

  @override
  String get errorNameRequired => 'أدخل اسمك الأول واسم العائلة.';

  @override
  String get errorNameLength => 'لازم يكون اسمك بين حرفين و٤٠ حرف.';
}
