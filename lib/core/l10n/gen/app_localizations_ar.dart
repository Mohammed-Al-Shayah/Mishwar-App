// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get planRide => 'خطّط مشوارك';

  @override
  String get currentLocation => 'موقعك الحالي';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get searchPlacesHint => 'اكتب اسم مكان أو شارع';

  @override
  String noPlacesFound(String query) {
    return 'ما لقينا نتائج لـ “$query”';
  }

  @override
  String get chooseRide => 'اختر الرحلة';

  @override
  String get whereTo => 'وين رايح؟';

  @override
  String get scheduleLater => 'لاحقاً';

  @override
  String get mapMobileOnly => 'الخريطة متاحة على تطبيق الموبايل';

  @override
  String get locationPermissionHint => 'اسمح بالموقع لنحدد نقطة انطلاقك.';

  @override
  String get allowLocation => 'اسمح بالموقع';

  @override
  String get openSettings => 'افتح الإعدادات';

  @override
  String get enableLocation => 'شغّل الموقع';

  @override
  String get locationForeverHint => 'فعّل صلاحية الموقع من إعدادات التطبيق.';

  @override
  String get locationServiceHint => 'شغّل خدمة الموقع لتحديد مكانك.';

  @override
  String get locationTimeout =>
      'تعذّر تحديد موقعك بالوقت المحدد. حاول مرة ثانية.';

  @override
  String get locationError => 'تعذّر تحديد موقعك. حاول مرة ثانية.';

  @override
  String get recenterMap => 'موقعي';

  @override
  String get openMenu => 'القائمة';

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

  @override
  String get driverRegisterTitle => 'سجّل سيارتك';

  @override
  String get driverReviewTime => 'بنراجع طلبك خلال 24 ساعة';

  @override
  String get vehicleTypeTitle => 'نوع السيارة';

  @override
  String get vehicleEconomy => 'اقتصادي';

  @override
  String get vehicleComfort => 'مريح';

  @override
  String get vehicleVan => 'عائلي';

  @override
  String get vehicleEconomyDescription => '4 ركاب، سعر أقل';

  @override
  String get vehicleComfortDescription => '4 ركاب، سيارة أحدث';

  @override
  String get vehicleVanDescription => 'حتى 6 ركاب';

  @override
  String get vehicleDetailsTitle => 'بيانات السيارة';

  @override
  String get vehicleMake => 'الشركة المصنّعة';

  @override
  String get vehicleModel => 'الموديل';

  @override
  String get vehicleColor => 'اللون';

  @override
  String get vehiclePlate => 'رقم اللوحة';

  @override
  String get vehiclePlateHint => '12-34567';

  @override
  String get licenseTitle => 'رخصة القيادة';

  @override
  String get photoChoose => 'أضف صورة الرخصة';

  @override
  String get photoChange => 'تغيير';

  @override
  String get photoSaved => 'صورة الرخصة محفوظة';

  @override
  String get photoCamera => 'الكاميرا';

  @override
  String get photoGallery => 'معرض الصور';

  @override
  String get driverSubmit => 'أرسل الطلب';

  @override
  String get driverPendingTitle => 'طلبك قيد المراجعة';

  @override
  String get driverPendingBody =>
      'بنراجع بياناتك ورخصتك خلال 24 ساعة. بنخبرك هون لما يتغيّر طلبك.';

  @override
  String get driverRejectedTitle => 'ما انقبل طلبك';

  @override
  String get driverRejectedBody => 'راجع بياناتك وعدّلها وأعد إرسال الطلب.';

  @override
  String get driverSuspendedTitle => 'حسابك موقوف مؤقتاً';

  @override
  String get driverSuspendedBody => 'تواصل مع الدعم للمساعدة بخصوص حسابك.';

  @override
  String get driverResubmit => 'عدّل وأعد الإرسال';

  @override
  String get errorVehicleLength => 'أدخل من حرفين إلى 30 حرفاً.';

  @override
  String get errorPlateFormat => 'أدخل رقم لوحة صحيح مثل 12-34567.';

  @override
  String get errorPhotoRequired => 'أضف صورة رخصة القيادة.';

  @override
  String vehicleSummary(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get economyTagline => 'رحلات بأسعار معقولة';

  @override
  String get comfortTagline => 'سيارات أحدث ومساحة أكبر';

  @override
  String get vanTagline => 'حتى 6 ركاب';

  @override
  String get cashPayment => 'كاش';

  @override
  String get confirmRetry => 'حاول مرة ثانية';

  @override
  String chooseVehicle(String vehicle) {
    return 'اختر $vehicle';
  }

  @override
  String tripPill(int minutes, String destination) {
    return '$minutes د · $destination';
  }

  @override
  String arrivalDuration(String time, int minutes) {
    return '$time · $minutes دقيقة';
  }

  @override
  String fareJod(String amount) {
    return 'JD $amount';
  }

  @override
  String get searchingTitle => 'بندوّر على أقرب سائق…';

  @override
  String get searchingQuick => 'عادة بياخذ أقل من دقيقة';

  @override
  String searchingVehicle(String vehicleName) {
    return 'منلاقيلك سيارة $vehicleName';
  }

  @override
  String get searchingNearby => 'بنتواصل مع السائقين القريبين';

  @override
  String get rideCancel => 'إلغاء الطلب';

  @override
  String get rideCancelTitle => 'متأكد بدك تلغي؟';

  @override
  String get rideKeepSearching => 'لا، كمّل';

  @override
  String get rideNoDrivers => 'ما لقينا سائق قريب';

  @override
  String get rideTryAgain => 'حاول مرة ثانية';

  @override
  String get rideBack => 'رجوع';

  @override
  String get rideAccepted => 'لقينا سائق!';

  @override
  String get driverStart => 'ابدأ';

  @override
  String get driverOffline => 'أنت غير متصل';

  @override
  String get driverOfflineHint => 'اتصل عشان تستقبل طلبات';

  @override
  String get driverOnline => 'أنت متصل';

  @override
  String get driverOnlineHint => 'بندوّر على طلبات قريبة…';

  @override
  String get driverStop => 'إنهاء';

  @override
  String get driverStopConfirm => 'بدك توقف استقبال الطلبات؟';

  @override
  String get driverKeepOnline => 'خليك متصل';

  @override
  String get driverEarnings => 'أرباح اليوم';

  @override
  String get driverEarningsAmount => 'JD 0.00';

  @override
  String get driverTrackingTitle => 'مشوار — أنت متصل';

  @override
  String get driverTrackingText =>
      'نحدّث موقعك لاستقبال طلبات المشاوير القريبة';

  @override
  String offerSeconds(int seconds) {
    return '$seconds ث';
  }

  @override
  String offerPickupDistance(int minutes, String km) {
    return '$minutes د · $km كم لعند الراكب';
  }

  @override
  String offerTripDistance(int minutes, String km) {
    return '$minutes د · $km كم';
  }

  @override
  String get offerAccept => 'قبول';

  @override
  String get offerDecline => 'رفض';

  @override
  String get offerLost => 'راح الطلب';

  @override
  String get driverHeadingToPickup => 'رايح لعند الراكب';

  @override
  String get offerNotOffered => 'الطلب مش معروض إلك';

  @override
  String get offerDriverBusy => 'عندك مشوار حالي';

  @override
  String get tripOnTrip => 'بالطريق للوجهة';

  @override
  String get tripCancel => 'إلغاء المشوار';

  @override
  String get tripCashPrompt => 'استلم كاش من الراكب';

  @override
  String get tripCall => 'اتصل بالراكب';

  @override
  String get tripNavigate => 'خرائط Google';

  @override
  String tripPrice(String amount) {
    return 'JD $amount';
  }

  @override
  String get tripToPickup => 'رايح لعند الراكب';

  @override
  String get tripArrived => 'وصلت';

  @override
  String get tripCompleteConfirm => 'وصلت للوجهة؟';

  @override
  String get tripCashCollected => 'استلمت المبلغ';

  @override
  String get tripComplete => 'إنهاء المشوار';

  @override
  String tripWaitingTime(String time) {
    return 'بتستنى من $time';
  }

  @override
  String get tripRedispatched => 'المشوار راح لسائق ثاني';

  @override
  String get tripCancelled => 'تم إلغاء المشوار';

  @override
  String get tripNo => 'لا';

  @override
  String tripRating(String rating) {
    return '$rating';
  }

  @override
  String get tripCancelConfirm => 'متأكد؟ رح يروح المشوار لسائق ثاني';

  @override
  String get tripMore => 'خيارات إضافية';

  @override
  String get tripWaiting => 'بانتظار الراكب';

  @override
  String get tripTooFar => 'لازم تكون قريب من نقطة الانطلاق';

  @override
  String get tripStart => 'ابدأ المشوار';

  @override
  String riderEta(int minutes) {
    return 'السائق بيوصل خلال $minutes د';
  }

  @override
  String get riderArrived => 'السائق وصل — هو بانتظارك';

  @override
  String riderArrival(String time) {
    return 'بتوصل الساعة $time';
  }

  @override
  String riderWaiting(int minutes) {
    return 'بانتظارك منذ $minutes د';
  }

  @override
  String get riderRedispatched => 'السائق لغى، بندوّر على سائق ثاني';

  @override
  String get riderCancelConfirm => 'متأكد بدك تلغي المشوار؟ السائق بالطريق';

  @override
  String get riderContinue => 'لا، كمّل';

  @override
  String get riderCall => 'اتصال';

  @override
  String get riderShare => 'مشاركة';

  @override
  String get riderSafety => 'الأمان';

  @override
  String riderRating(String rating) {
    return '★ $rating';
  }

  @override
  String riderVehicle(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get riderCash => 'كاش';

  @override
  String get riderCashNote => 'ادفع للسائق كاش';

  @override
  String get riderCompleted => 'وصلت!';

  @override
  String get riderDone => 'تم';

  @override
  String get riderRecenter => 'رجّع الخريطة';

  @override
  String get riderCancel => 'إلغاء المشوار';
}
