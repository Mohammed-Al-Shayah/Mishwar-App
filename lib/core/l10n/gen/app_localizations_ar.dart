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
  String get errorNameLength => 'لازم يكون اسمك بين حرفين و 40 حرف.';

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

  @override
  String ratingRiderTitle(String name) {
    return 'كيف كان مشوارك مع $name؟';
  }

  @override
  String ratingDriverTitle(String name) {
    return 'قيّم $name';
  }

  @override
  String get ratingComment => 'بدك تضيف ملاحظة؟';

  @override
  String get ratingSubmit => 'إرسال';

  @override
  String get ratingSkip => 'تخطي';

  @override
  String ratingStars(int count) {
    return '$count من 5';
  }

  @override
  String get ratingTagSafeDriving => 'قيادة آمنة';

  @override
  String get ratingTagCleanCar => 'سيارة نظيفة';

  @override
  String get ratingTagFriendly => 'لطيف';

  @override
  String get ratingTagKnowsRoute => 'بعرف الطريق';

  @override
  String get ratingTagLate => 'متأخر';

  @override
  String get ratingTagFastDriving => 'قيادة سريعة';

  @override
  String get ratingTagDirtyCar => 'سيارة مش نظيفة';

  @override
  String get ratingTagLongerRoute => 'طريق أطول';

  @override
  String get ratingTagOnTime => 'على الموعد';

  @override
  String get ratingTagRespectful => 'محترم';

  @override
  String get ratingTagRude => 'غير محترم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAccount => 'الحساب';

  @override
  String get historyTitle => 'النشاط';

  @override
  String get historyEmptyTitle => 'ما عندك مشاوير لسا';

  @override
  String get historyEmptyBody => 'مشاويرك السابقة رح تظهر هون بعد أول مشوار.';

  @override
  String get historyCancelled => 'ملغي';

  @override
  String get historyNoDrivers => 'ما توفر سائقين';

  @override
  String historyStatusSuffix(String status) {
    return ' · $status';
  }

  @override
  String historyRoute(String pickup, String dropoff) {
    return '$pickup ← $dropoff';
  }

  @override
  String get receiptTitle => 'فاتورة المشوار';

  @override
  String get receiptFare => 'الأجرة';

  @override
  String get receiptPayment => 'طريقة الدفع';

  @override
  String get receiptTotal => 'المجموع';

  @override
  String get receiptYourRating => 'تقييمك';

  @override
  String receiptStars(int stars) {
    return '$stars نجوم';
  }

  @override
  String receiptVehicle(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get receiptRebook => 'اطلب نفس المشوار';

  @override
  String get earningsTitle => 'الأرباح';

  @override
  String earningsTrips(int count) {
    return '$count مشاوير';
  }

  @override
  String get earningsDayTrips => 'مشاوير هذا اليوم';

  @override
  String get earningsNoTrips => 'ما في مشاوير بهذا اليوم';

  @override
  String earningsBarLabel(String day, String amount) {
    return '$day، JD $amount';
  }

  @override
  String get accountProfile => 'الملف الشخصي';

  @override
  String get accountLanguage => 'اللغة';

  @override
  String get accountAppearance => 'المظهر';

  @override
  String get accountSystem => 'تلقائي';

  @override
  String get accountLight => 'فاتح';

  @override
  String get accountDark => 'غامق';

  @override
  String get accountDrive => 'اشتغل سائق معنا';

  @override
  String get accountRide => 'التبديل لوضع الراكب';

  @override
  String get accountVehicle => 'السيارة';

  @override
  String get accountTerms => 'الشروط والأحكام';

  @override
  String get accountPrivacy => 'سياسة الخصوصية';

  @override
  String get accountAbout => 'عن التطبيق';

  @override
  String get accountSave => 'حفظ';

  @override
  String get accountCancel => 'إلغاء';

  @override
  String get accountConfirm => 'تأكيد';

  @override
  String get accountSwitchConfirm => 'بدك تغيّر وضع الحساب؟';

  @override
  String get accountSignOutConfirm => 'بدك تسجّل الخروج؟';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get accountDeleteWarning =>
      'حذف الحساب نهائي، وما بتقدر ترجّعه. رح نحذف ملفك وبيانات سيارتك، ونحتفظ بسجلات المشاوير بدون اسمك ورقمك.';

  @override
  String get accountDeletePrompt => 'اكتب حذف للتأكيد';

  @override
  String get accountDeleteWord => 'حذف';

  @override
  String get accountBusy => 'خلّص المشوار الحالي أول';

  @override
  String get accountName => 'الاسم';

  @override
  String get accountNameError => 'الاسم لازم يكون من حرفين لـ 40 حرف';

  @override
  String get accountVersion => 'الإصدار';

  @override
  String get accountArabic => 'العربية';

  @override
  String get accountEnglish => 'English';

  @override
  String get adminOverview => 'نظرة عامة';

  @override
  String get adminDrivers => 'السائقين';

  @override
  String get adminRides => 'المشاوير';

  @override
  String get adminMap => 'الخريطة المباشرة';

  @override
  String get adminPricing => 'الأسعار';

  @override
  String get adminSignIn => 'دخول الأدمن';

  @override
  String get adminEmail => 'البريد الإلكتروني';

  @override
  String get adminPassword => 'كلمة المرور';

  @override
  String get adminDenied => 'هاد الحساب مش أدمن';

  @override
  String get adminSignOut => 'تسجيل الخروج';

  @override
  String get adminLargeScreen => 'افتح من شاشة أكبر';

  @override
  String get adminError => 'تعذّر تنفيذ الطلب. حاول مرة ثانية.';

  @override
  String get adminRetry => 'حاول مرة ثانية';

  @override
  String get adminEmpty => 'ما في نتائج';

  @override
  String get adminOnline => 'السائقين المتصلين';

  @override
  String get adminActive => 'المشاوير الفعّالة';

  @override
  String get adminTodayRides => 'مشاوير اليوم';

  @override
  String get adminPendingApplications => 'طلبات بانتظار المراجعة';

  @override
  String get adminLatest => 'آخر 10 مشاوير';

  @override
  String get adminPending => 'بانتظار المراجعة';

  @override
  String get adminApproved => 'مقبولين';

  @override
  String get adminSuspended => 'موقوفين';

  @override
  String get adminRejected => 'مرفوضين';

  @override
  String get adminSearch => 'ابحث بالاسم، الجوال أو اللوحة';

  @override
  String get adminName => 'الاسم';

  @override
  String get adminPhone => 'الجوال';

  @override
  String get adminVehicle => 'السيارة';

  @override
  String get adminPlate => 'اللوحة';

  @override
  String get adminStatus => 'الحالة';

  @override
  String get adminRating => 'التقييم';

  @override
  String get adminApplied => 'تاريخ التقديم';

  @override
  String get adminPrevious => 'السابق';

  @override
  String get adminNext => 'التالي';

  @override
  String get adminTime => 'الوقت';

  @override
  String get adminRider => 'الراكب';

  @override
  String get adminDriver => 'السائق';

  @override
  String get adminRoute => 'الانطلاق ← الوجهة';

  @override
  String get adminFare => 'الأجرة';

  @override
  String get adminAll => 'الكل';

  @override
  String get adminSearching => 'جاري البحث';

  @override
  String get adminAccepted => 'مقبول';

  @override
  String get adminArriving => 'السائق بالطريق';

  @override
  String get adminArrived => 'السائق وصل';

  @override
  String get adminInProgress => 'جاري المشوار';

  @override
  String get adminCompleted => 'مكتمل';

  @override
  String get adminCancelled => 'ملغي';

  @override
  String get adminNoDrivers => 'ما في سائقين';

  @override
  String get adminToday => 'اليوم';

  @override
  String get adminWeek => '7 أيام';

  @override
  String get adminCustom => 'فترة مخصصة';

  @override
  String get adminApprove => 'موافقة';

  @override
  String get adminReject => 'رفض';

  @override
  String get adminSuspend => 'إيقاف';

  @override
  String get adminReactivate => 'إعادة تفعيل';

  @override
  String get adminReason => 'السبب (حتى 200 حرف)';

  @override
  String get adminConfirm => 'تأكيد';

  @override
  String get adminDismiss => 'رجوع';

  @override
  String get adminCancelRide => 'إلغاء المشوار';

  @override
  String get adminLicense => 'صورة الرخصة';

  @override
  String get adminLicenseMissing => 'ما في صورة رخصة مرفوعة';

  @override
  String get adminHistory => 'السجل';

  @override
  String get adminCompletedTrips => 'المشاوير المكتملة';

  @override
  String get adminCancellations => 'الإلغاءات';

  @override
  String get adminEstimated => 'الأجرة التقديرية';

  @override
  String get adminFinal => 'الأجرة النهائية';

  @override
  String get adminTimeline => 'التسلسل الزمني';

  @override
  String get adminRiderRating => 'تقييم الراكب';

  @override
  String get adminDriverRating => 'تقييم السائق';

  @override
  String get adminClose => 'إغلاق';

  @override
  String get adminMapFallback =>
      'مفتاح الخريطة غير متوفر. مواقع السائقين معروضة بالقائمة.';

  @override
  String get adminMapFailed =>
      'تعذّر تحميل الخريطة. مواقع السائقين معروضة بالقائمة.';

  @override
  String get adminFree => 'متاح';

  @override
  String get adminBusy => 'بمشوار';

  @override
  String get adminCoordinates => 'الإحداثيات';

  @override
  String get adminEconomy => 'اقتصادي';

  @override
  String get adminComfort => 'مريح';

  @override
  String get adminVan => 'فان';

  @override
  String get adminBase => 'الأساس';

  @override
  String get adminPerKm => 'لكل كم';

  @override
  String get adminPerMin => 'لكل دقيقة';

  @override
  String get adminMinimum => 'الحد الأدنى';

  @override
  String get adminPreview => 'تقدير 10 كم / 20 دقيقة';

  @override
  String get adminSave => 'حفظ';

  @override
  String get adminRateInvalid =>
      'أدخل قيمة أكبر من 0 وحتى 50، بحد أقصى 3 منازل عشرية';

  @override
  String get adminUpdatedBy => 'آخر تعديل بواسطة';

  @override
  String get adminUpdatedAt => 'آخر تعديل بتاريخ';

  @override
  String get adminSaved => 'تم الحفظ';

  @override
  String get adminCurrency => 'د.أ';

  @override
  String get adminUnknown => '—';

  @override
  String get adminLanguage => 'اللغة';

  @override
  String get savedPlaces => 'الأماكن المحفوظة';

  @override
  String get savedPlaceHome => 'البيت';

  @override
  String get savedPlaceWork => 'الشغل';

  @override
  String get savedPlaceOther => 'مكان آخر';

  @override
  String get savedPlaceAddHome => 'أضف البيت';

  @override
  String get savedPlaceAddWork => 'أضف الشغل';

  @override
  String get savedPlaceTapToSet => 'اضغط عشان تحدد الموقع';

  @override
  String get savedPlaceAdd => 'إضافة مكان';

  @override
  String get savedPlaceEdit => 'تعديل المكان';

  @override
  String get savedPlaceType => 'النوع';

  @override
  String get savedPlaceName => 'اسم المكان';

  @override
  String get savedPlaceChooseLocation => 'اختر الموقع';

  @override
  String get savedPlaceDelete => 'حذف المكان';

  @override
  String savedPlaceDeleteConfirm(String name) {
    return 'بدك تحذف \"$name\"؟';
  }

  @override
  String get savedPlacesEmpty => 'ما عندك أماكن محفوظة';

  @override
  String get savedPlacesEmptyHint => 'احفظ البيت والشغل عشان توصلهم بضغطة وحدة';

  @override
  String get savedPlaceLimit => 'وصلت للحد الأقصى: 20 مكان';

  @override
  String get savedPlaceInvalid => 'تأكد من الاسم والموقع';

  @override
  String get recentPlaces => 'آخر الأماكن';

  @override
  String get scheduleTitle => 'متى بدك تطلع؟';

  @override
  String get scheduleToday => 'اليوم';

  @override
  String get scheduleTomorrow => 'بكرا';

  @override
  String get scheduleOtherDate => 'تاريخ آخر';

  @override
  String get scheduleWindow => 'احجز من 30 دقيقة لحد 30 يوم لقدام';

  @override
  String get scheduleConfirm => 'تأكيد الموعد';

  @override
  String get scheduleClear => 'إلغاء الموعد المحدد';

  @override
  String get scheduleSuccess => 'انحجز مشوارك';

  @override
  String scheduledDeparture(String time) {
    return 'موعد الانطلاق · $time';
  }

  @override
  String scheduleVehicle(String vehicle) {
    return 'احجز $vehicle';
  }

  @override
  String get scheduledSection => 'المجدولة';

  @override
  String get scheduledCancelTitle => 'بدك تلغي مشوارك المجدول؟';

  @override
  String get scheduledCancelConfirm => 'إلغاء المشوار';

  @override
  String get scheduledKeep => 'خلي المشوار';

  @override
  String get scheduledCancel => 'إلغاء';

  @override
  String get tooManyScheduled =>
      'بتقدر تحجز 3 مشاوير مجدولة. إلغي واحد عشان تحجز مشوار جديد.';

  @override
  String get promoAdd => 'إضافة كود خصم';

  @override
  String get promoApply => 'تطبيق';

  @override
  String get promoCodeLabel => 'كود الخصم';

  @override
  String get promoRemove => 'إزالة كود الخصم';

  @override
  String promoSelected(String code, String amount) {
    return '$code · خصم JD $amount';
  }

  @override
  String promoDiscount(String code, String amount) {
    return 'خصم ($code) − JD $amount';
  }

  @override
  String promoCashFootnote(String amount) {
    return 'شامل خصم JD $amount';
  }

  @override
  String get promoNotFound => 'الكود مش صحيح';

  @override
  String get promoInactive => 'الكود مش فعّال';

  @override
  String get promoNotStarted => 'الكود لسه ما بلّش';

  @override
  String get promoExpired => 'انتهت صلاحية الكود';

  @override
  String get promoLimit => 'وصل الكود للحد الأقصى';

  @override
  String get promoUserLimit => 'استخدمت الكود قبل';

  @override
  String get promoFirstRide => 'الكود لأول مشوار بس';

  @override
  String promoMinFare(String amount) {
    return 'أقل سعر للكود JD $amount';
  }

  @override
  String get promoRateLimit => 'جربت أكواد كتير، جرّب بعد شوي';

  @override
  String get adminContent => 'المحتوى';

  @override
  String get contentBanners => 'البانرات';

  @override
  String get contentAddBanner => 'إضافة بانر';

  @override
  String get contentEditBanner => 'تعديل البانر';

  @override
  String get contentTitle => 'العنوان';

  @override
  String get contentSubtitle => 'النص الفرعي';

  @override
  String get contentImage => 'رابط الصورة (https)';

  @override
  String get contentAction => 'الإجراء';

  @override
  String get contentSearch => 'فتح البحث';

  @override
  String get contentPromo => 'كود خصم';

  @override
  String get contentUrl => 'رابط خارجي (https)';

  @override
  String get contentOrder => 'الترتيب';

  @override
  String get contentValidUntil => 'صالح حتى';

  @override
  String get contentActive => 'نشط';

  @override
  String get contentSave => 'حفظ';

  @override
  String get contentDelete => 'حذف';

  @override
  String get contentDeleteConfirm => 'حذف هذا البانر؟';

  @override
  String get contentCancel => 'إلغاء';

  @override
  String get contentInvalid => 'تحقق من القيمة المدخلة';

  @override
  String get contentMoveUp => 'تحريك لأعلى';

  @override
  String get contentMoveDown => 'تحريك لأسفل';

  @override
  String get contentServices => 'الخدمات';

  @override
  String get contentEnabled => 'مفعّل';

  @override
  String bannerPage(int page, int total) {
    return 'العرض $page من $total';
  }

  @override
  String get contentLinkError => 'تعذّر فتح الرابط';

  @override
  String get servicesSuggestions => 'الاقتراحات';

  @override
  String get servicesAll => 'الكل';

  @override
  String get serviceRide => 'رحلة';

  @override
  String get serviceSchedule => 'احجز';

  @override
  String get serviceParcel => 'طرد';

  @override
  String get serviceAirport => 'مطار';

  @override
  String get serviceSoon => 'قريباً';

  @override
  String get serviceSoonMessage => 'الخدمة قريباً';

  @override
  String get serviceRideDescription => 'اطلب مشواراً الآن';

  @override
  String get serviceScheduleDescription => 'اختر موعد مشوارك';

  @override
  String get serviceParcelDescription => 'أرسل طرداً';

  @override
  String get serviceAirportDescription => 'مشاوير من وإلى المطار';

  @override
  String cancellationFeeWarning(String amount) {
    return 'إذا لغيت هلأ رح يترتب عليك رسوم إلغاء $amount بتنضاف على مشوارك الجاي';
  }

  @override
  String freeWaitingCountdown(String time) {
    return 'انتظار مجاني $time';
  }

  @override
  String waitingFeeRate(String amount) {
    return 'رسوم انتظار $amount للدقيقة';
  }

  @override
  String waitingFeeRunning(String amount) {
    return 'رسوم انتظار: $amount';
  }

  @override
  String get feeWaiting => 'رسوم انتظار';

  @override
  String get feePreviousBalance => 'رسوم إلغاء سابقة';

  @override
  String get feeCancellation => 'رسوم الإلغاء';

  @override
  String cancellationBalanceInfo(String amount) {
    return 'عليك $amount رسوم إلغاء، بتنضاف على مشوارك الجاي';
  }

  @override
  String get safetyTitle => 'الأمان';

  @override
  String get trustedContacts => 'جهات الاتصال الموثوقة';

  @override
  String get contactsEmpty => 'أضف من تثق بهم';

  @override
  String get contactsExplanation =>
      'احفظ حتى خمسة أشخاص لإرسال موقعك لهم عند الحاجة.';

  @override
  String get contactAdd => 'إضافة جهة اتصال';

  @override
  String get contactEdit => 'تعديل جهة الاتصال';

  @override
  String get contactDelete => 'حذف جهة الاتصال';

  @override
  String contactDeleteConfirm(String name) {
    return 'هل تريد حذف $name؟';
  }

  @override
  String get contactName => 'الاسم';

  @override
  String get contactPhone => 'رقم الجوال الأردني';

  @override
  String get contactInvalid =>
      'أدخل اسماً من 1 إلى 40 حرفاً ورقم جوال أردني صحيح.';

  @override
  String get contactsLimit => 'يمكنك إضافة خمس جهات اتصال كحد أقصى.';

  @override
  String get emergencySettings => 'إعدادات الطوارئ';

  @override
  String get emergencyFootnote => 'رقم الطوارئ في الأردن 911';

  @override
  String get safetyToolkit => 'أدوات الأمان';

  @override
  String get emergencyCall => 'اتصل بالطوارئ (911)';

  @override
  String get emergencyConfirm => 'هل تريد الاتصال بالطوارئ على 911؟';

  @override
  String get safetySms => 'أرسل موقعي لجهات الاتصال الموثوقة';

  @override
  String get safetyNoContacts => 'أضف جهات اتصال من الأمان';

  @override
  String get safetyShare => 'شارك تفاصيل المشوار';

  @override
  String shareTripText(String driver, String url) {
    return 'تابع مشواري مع $driver على مشوار: $url';
  }

  @override
  String safetySmsBody(
    String driver,
    String car,
    String plate,
    String coordinates,
  ) {
    return 'أنا بمشوار مع $driver ($car $plate). موقعي: https://maps.google.com/?q=$coordinates';
  }

  @override
  String safetyDriverSmsBody(String coordinates) {
    return 'موقعي: https://maps.google.com/?q=$coordinates';
  }

  @override
  String get activityUpcoming => 'الجاية';

  @override
  String get activityPast => 'السابقة';

  @override
  String get activityUpcomingEmpty =>
      'ما عندك مشاوير جاية. احجز مشوار من الرئيسية.';

  @override
  String get receiptReport => 'الإبلاغ عن مشكلة';

  @override
  String get receiptShare => 'مشاركة الفاتورة';

  @override
  String get receiptCancelledRider => 'ألغى الراكب المشوار';

  @override
  String get receiptCancelledDriver => 'ألغى السائق المشوار';

  @override
  String get receiptCancelledSystem => 'أُلغي المشوار من النظام';

  @override
  String get supportTitle => 'الدعم';

  @override
  String get supportNew => 'طلب مساعدة جديد';

  @override
  String get supportEmpty => 'ما عندك طلبات دعم';

  @override
  String get supportOpen => 'مفتوح';

  @override
  String get supportInProgress => 'قيد المعالجة';

  @override
  String get supportClosed => 'مغلق';

  @override
  String get supportLostItem => 'أغراض منسية';

  @override
  String get supportFare => 'السعر';

  @override
  String get supportSafety => 'الأمان';

  @override
  String get supportOther => 'إشي ثاني';

  @override
  String get supportMessage => 'رسالتك';

  @override
  String get supportSend => 'إرسال';

  @override
  String get supportClosedNote =>
      'هالطلب مسكّر. إذا لسا بدك مساعدة افتح طلب جديد.';

  @override
  String get supportMessageInvalid => 'اكتب رسالة من حرف لـ 1000 حرف.';

  @override
  String get supportLimit =>
      'عندك 5 طلبات لسا مفتوحة. استنى لحد ما يتسكّر واحد منهم.';

  @override
  String get supportUnread => 'رد جديد من الدعم';

  @override
  String get supportRole => 'الوضع';

  @override
  String get supportCategory => 'التصنيف';

  @override
  String get supportRide => 'المشوار';

  @override
  String get supportLastMessage => 'آخر رسالة';

  @override
  String get supportUser => 'المستخدم';

  @override
  String get supportStatus => 'الحالة';

  @override
  String get supportUserMessage => 'أنت';

  @override
  String get supportAdminMessage => 'فريق الدعم';

  @override
  String get supportRider => 'راكب';

  @override
  String get supportDriver => 'سائق';

  @override
  String get parcelTitle => 'توصيل طرد';

  @override
  String get parcelRecipient => 'اسم المستلم';

  @override
  String get parcelDescription => 'شو في بالطرد؟';

  @override
  String get parcelPhoto => 'صورة الطرد';

  @override
  String get parcelPhotoOptional => 'اختياري — صورة بتساعد السائق يعرف الطرد';

  @override
  String get parcelPhotoUploaded => 'الصورة جاهزة، اضغط لتغيّرها';

  @override
  String get parcelInvalid =>
      'اكتب اسم المستلم ورقمه ووصف للطرد، وتأكد إنهم صح';

  @override
  String get parcelContinue => 'كمّل واختار الوجهة';

  @override
  String get parcelRequest => 'اطلب توصيل';

  @override
  String parcelCode(String code) {
    return 'رمز التسليم: $code — أعطيه للمستلم';
  }

  @override
  String get parcelSendCode => 'أرسل الرمز للمستلم';

  @override
  String parcelSms(String code) {
    return 'مشوار: رمز استلام طردك $code';
  }

  @override
  String get parcelDeliver => 'تسليم الطرد';

  @override
  String get parcelEnterCode => 'اطلب من المستلم رمز التسليم من 4 أرقام';

  @override
  String get parcelBadCode => 'الرمز مش صح، جرّب كمان مرة';

  @override
  String get parcelCodeLocked =>
      'وصلت لـ 5 محاولات، تواصل مع الدعم عشان تكمّل التسليم';

  @override
  String get parcelSupport => 'تواصل مع الدعم';

  @override
  String get parcelServiceDisabled => 'توصيل الطرود مش متاح هلأ، جرّب بعدين';
}
