import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @planRide.
  ///
  /// In ar, this message translates to:
  /// **'خطّط مشوارك'**
  String get planRide;

  /// No description provided for @currentLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقعك الحالي'**
  String get currentLocation;

  /// No description provided for @clearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearch;

  /// No description provided for @searchPlacesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم مكان أو شارع'**
  String get searchPlacesHint;

  /// No description provided for @noPlacesFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا نتائج لـ “{query}”'**
  String noPlacesFound(String query);

  /// No description provided for @chooseRide.
  ///
  /// In ar, this message translates to:
  /// **'اختر الرحلة'**
  String get chooseRide;

  /// No description provided for @whereTo.
  ///
  /// In ar, this message translates to:
  /// **'وين رايح؟'**
  String get whereTo;

  /// No description provided for @scheduleLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get scheduleLater;

  /// No description provided for @mapMobileOnly.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة متاحة على تطبيق الموبايل'**
  String get mapMobileOnly;

  /// No description provided for @locationPermissionHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمح بالموقع لنحدد نقطة انطلاقك.'**
  String get locationPermissionHint;

  /// No description provided for @allowLocation.
  ///
  /// In ar, this message translates to:
  /// **'اسمح بالموقع'**
  String get allowLocation;

  /// No description provided for @openSettings.
  ///
  /// In ar, this message translates to:
  /// **'افتح الإعدادات'**
  String get openSettings;

  /// No description provided for @enableLocation.
  ///
  /// In ar, this message translates to:
  /// **'شغّل الموقع'**
  String get enableLocation;

  /// No description provided for @locationForeverHint.
  ///
  /// In ar, this message translates to:
  /// **'فعّل صلاحية الموقع من إعدادات التطبيق.'**
  String get locationForeverHint;

  /// No description provided for @locationServiceHint.
  ///
  /// In ar, this message translates to:
  /// **'شغّل خدمة الموقع لتحديد مكانك.'**
  String get locationServiceHint;

  /// No description provided for @locationTimeout.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك بالوقت المحدد. حاول مرة ثانية.'**
  String get locationTimeout;

  /// No description provided for @locationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك. حاول مرة ثانية.'**
  String get locationError;

  /// No description provided for @recenterMap.
  ///
  /// In ar, this message translates to:
  /// **'موقعي'**
  String get recenterMap;

  /// No description provided for @openMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get openMenu;

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'مشوار'**
  String get appName;

  /// No description provided for @roleTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف بدك تستخدم مشوار؟'**
  String get roleTitle;

  /// No description provided for @roleRider.
  ///
  /// In ar, this message translates to:
  /// **'بدي أطلب مشوار'**
  String get roleRider;

  /// No description provided for @roleRiderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اطلب سيارة لوين ما بدك'**
  String get roleRiderSubtitle;

  /// No description provided for @roleDriver.
  ///
  /// In ar, this message translates to:
  /// **'بدي أشتغل سائق'**
  String get roleDriver;

  /// No description provided for @roleDriverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكسب على وقتك'**
  String get roleDriverSubtitle;

  /// No description provided for @riderMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الراكب'**
  String get riderMode;

  /// No description provided for @driverMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع السائق'**
  String get driverMode;

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @phoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم موبايلك'**
  String get phoneTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phoneLabel;

  /// No description provided for @countryCode.
  ///
  /// In ar, this message translates to:
  /// **'🇯🇴 +962'**
  String get countryCode;

  /// No description provided for @smsFootnote.
  ///
  /// In ar, this message translates to:
  /// **'رح نبعتلك رسالة SMS فيها رمز التحقق.'**
  String get smsFootnote;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز'**
  String get otpTitle;

  /// No description provided for @otpSent.
  ///
  /// In ar, this message translates to:
  /// **'بعتنالك رمز على {phone}'**
  String otpSent(String phone);

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendCode;

  /// No description provided for @resendCountdown.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ث'**
  String resendCountdown(int seconds);

  /// No description provided for @editPhone.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الرقم'**
  String get editPhone;

  /// No description provided for @nameTitle.
  ///
  /// In ar, this message translates to:
  /// **'شو اسمك؟'**
  String get nameTitle;

  /// No description provided for @firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العائلة'**
  String get lastName;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @signOutLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOutLabel;

  /// No description provided for @retryLabel.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة ثانية'**
  String get retryLabel;

  /// No description provided for @otpDigit.
  ///
  /// In ar, this message translates to:
  /// **'خانة الرمز {digit}'**
  String otpDigit(int digit);

  /// No description provided for @errorInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم موبايل صحيح.'**
  String get errorInvalidPhone;

  /// No description provided for @errorInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز مش صحيح. جرّب مرة ثانية.'**
  String get errorInvalidCode;

  /// No description provided for @errorCodeExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الرمز. اطلب رمز جديد.'**
  String get errorCodeExpired;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. جرّب بعد شوي.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من اتصال الإنترنت وجرّب مرة ثانية.'**
  String get errorNetwork;

  /// No description provided for @errorQuota.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل مش متاحة حالياً. جرّب بعد شوي.'**
  String get errorQuota;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ. جرّب مرة ثانية.'**
  String get errorGeneric;

  /// No description provided for @errorNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الأول واسم العائلة.'**
  String get errorNameRequired;

  /// No description provided for @errorNameLength.
  ///
  /// In ar, this message translates to:
  /// **'لازم يكون اسمك بين حرفين و٤٠ حرف.'**
  String get errorNameLength;

  /// No description provided for @driverRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل سيارتك'**
  String get driverRegisterTitle;

  /// No description provided for @driverReviewTime.
  ///
  /// In ar, this message translates to:
  /// **'بنراجع طلبك خلال 24 ساعة'**
  String get driverReviewTime;

  /// No description provided for @vehicleTypeTitle.
  ///
  /// In ar, this message translates to:
  /// **'نوع السيارة'**
  String get vehicleTypeTitle;

  /// No description provided for @vehicleEconomy.
  ///
  /// In ar, this message translates to:
  /// **'اقتصادي'**
  String get vehicleEconomy;

  /// No description provided for @vehicleComfort.
  ///
  /// In ar, this message translates to:
  /// **'مريح'**
  String get vehicleComfort;

  /// No description provided for @vehicleVan.
  ///
  /// In ar, this message translates to:
  /// **'عائلي'**
  String get vehicleVan;

  /// No description provided for @vehicleEconomyDescription.
  ///
  /// In ar, this message translates to:
  /// **'4 ركاب، سعر أقل'**
  String get vehicleEconomyDescription;

  /// No description provided for @vehicleComfortDescription.
  ///
  /// In ar, this message translates to:
  /// **'4 ركاب، سيارة أحدث'**
  String get vehicleComfortDescription;

  /// No description provided for @vehicleVanDescription.
  ///
  /// In ar, this message translates to:
  /// **'حتى 6 ركاب'**
  String get vehicleVanDescription;

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات السيارة'**
  String get vehicleDetailsTitle;

  /// No description provided for @vehicleMake.
  ///
  /// In ar, this message translates to:
  /// **'الشركة المصنّعة'**
  String get vehicleMake;

  /// No description provided for @vehicleModel.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get vehicleModel;

  /// No description provided for @vehicleColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get vehicleColor;

  /// No description provided for @vehiclePlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get vehiclePlate;

  /// No description provided for @vehiclePlateHint.
  ///
  /// In ar, this message translates to:
  /// **'12-34567'**
  String get vehiclePlateHint;

  /// No description provided for @licenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'رخصة القيادة'**
  String get licenseTitle;

  /// No description provided for @photoChoose.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة الرخصة'**
  String get photoChoose;

  /// No description provided for @photoChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get photoChange;

  /// No description provided for @photoSaved.
  ///
  /// In ar, this message translates to:
  /// **'صورة الرخصة محفوظة'**
  String get photoSaved;

  /// No description provided for @photoCamera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get photoCamera;

  /// No description provided for @photoGallery.
  ///
  /// In ar, this message translates to:
  /// **'معرض الصور'**
  String get photoGallery;

  /// No description provided for @driverSubmit.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الطلب'**
  String get driverSubmit;

  /// No description provided for @driverPendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المراجعة'**
  String get driverPendingTitle;

  /// No description provided for @driverPendingBody.
  ///
  /// In ar, this message translates to:
  /// **'بنراجع بياناتك ورخصتك خلال 24 ساعة. بنخبرك هون لما يتغيّر طلبك.'**
  String get driverPendingBody;

  /// No description provided for @driverRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما انقبل طلبك'**
  String get driverRejectedTitle;

  /// No description provided for @driverRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع بياناتك وعدّلها وأعد إرسال الطلب.'**
  String get driverRejectedBody;

  /// No description provided for @driverSuspendedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موقوف مؤقتاً'**
  String get driverSuspendedTitle;

  /// No description provided for @driverSuspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم للمساعدة بخصوص حسابك.'**
  String get driverSuspendedBody;

  /// No description provided for @driverResubmit.
  ///
  /// In ar, this message translates to:
  /// **'عدّل وأعد الإرسال'**
  String get driverResubmit;

  /// No description provided for @errorVehicleLength.
  ///
  /// In ar, this message translates to:
  /// **'أدخل من حرفين إلى 30 حرفاً.'**
  String get errorVehicleLength;

  /// No description provided for @errorPlateFormat.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم لوحة صحيح مثل 12-34567.'**
  String get errorPlateFormat;

  /// No description provided for @errorPhotoRequired.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة رخصة القيادة.'**
  String get errorPhotoRequired;

  /// No description provided for @vehicleSummary.
  ///
  /// In ar, this message translates to:
  /// **'{make} {model} · {color}'**
  String vehicleSummary(String make, String model, String color);

  /// No description provided for @economyTagline.
  ///
  /// In ar, this message translates to:
  /// **'رحلات بأسعار معقولة'**
  String get economyTagline;

  /// No description provided for @comfortTagline.
  ///
  /// In ar, this message translates to:
  /// **'سيارات أحدث ومساحة أكبر'**
  String get comfortTagline;

  /// No description provided for @vanTagline.
  ///
  /// In ar, this message translates to:
  /// **'حتى 6 ركاب'**
  String get vanTagline;

  /// No description provided for @cashPayment.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get cashPayment;

  /// No description provided for @confirmRetry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة ثانية'**
  String get confirmRetry;

  /// No description provided for @chooseVehicle.
  ///
  /// In ar, this message translates to:
  /// **'اختر {vehicle}'**
  String chooseVehicle(String vehicle);

  /// No description provided for @tripPill.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د · {destination}'**
  String tripPill(int minutes, String destination);

  /// No description provided for @arrivalDuration.
  ///
  /// In ar, this message translates to:
  /// **'{time} · {minutes} دقيقة'**
  String arrivalDuration(String time, int minutes);

  /// No description provided for @fareJod.
  ///
  /// In ar, this message translates to:
  /// **'JD {amount}'**
  String fareJod(String amount);

  /// No description provided for @searchingTitle.
  ///
  /// In ar, this message translates to:
  /// **'بندوّر على أقرب سائق…'**
  String get searchingTitle;

  /// No description provided for @searchingQuick.
  ///
  /// In ar, this message translates to:
  /// **'عادة بياخذ أقل من دقيقة'**
  String get searchingQuick;

  /// No description provided for @searchingVehicle.
  ///
  /// In ar, this message translates to:
  /// **'منلاقيلك سيارة {vehicleName}'**
  String searchingVehicle(String vehicleName);

  /// No description provided for @searchingNearby.
  ///
  /// In ar, this message translates to:
  /// **'بنتواصل مع السائقين القريبين'**
  String get searchingNearby;

  /// No description provided for @rideCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get rideCancel;

  /// No description provided for @rideCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'متأكد بدك تلغي؟'**
  String get rideCancelTitle;

  /// No description provided for @rideKeepSearching.
  ///
  /// In ar, this message translates to:
  /// **'لا، كمّل'**
  String get rideKeepSearching;

  /// No description provided for @rideNoDrivers.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا سائق قريب'**
  String get rideNoDrivers;

  /// No description provided for @rideTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة ثانية'**
  String get rideTryAgain;

  /// No description provided for @rideBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get rideBack;

  /// No description provided for @rideAccepted.
  ///
  /// In ar, this message translates to:
  /// **'لقينا سائق!'**
  String get rideAccepted;

  /// No description provided for @driverStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get driverStart;

  /// No description provided for @driverOffline.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل'**
  String get driverOffline;

  /// No description provided for @driverOfflineHint.
  ///
  /// In ar, this message translates to:
  /// **'اتصل عشان تستقبل طلبات'**
  String get driverOfflineHint;

  /// No description provided for @driverOnline.
  ///
  /// In ar, this message translates to:
  /// **'أنت متصل'**
  String get driverOnline;

  /// No description provided for @driverOnlineHint.
  ///
  /// In ar, this message translates to:
  /// **'بندوّر على طلبات قريبة…'**
  String get driverOnlineHint;

  /// No description provided for @driverStop.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get driverStop;

  /// No description provided for @driverStopConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بدك توقف استقبال الطلبات؟'**
  String get driverStopConfirm;

  /// No description provided for @driverKeepOnline.
  ///
  /// In ar, this message translates to:
  /// **'خليك متصل'**
  String get driverKeepOnline;

  /// No description provided for @driverEarnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباح اليوم'**
  String get driverEarnings;

  /// No description provided for @driverEarningsAmount.
  ///
  /// In ar, this message translates to:
  /// **'JD 0.00'**
  String get driverEarningsAmount;

  /// No description provided for @driverTrackingTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشوار — أنت متصل'**
  String get driverTrackingTitle;

  /// No description provided for @driverTrackingText.
  ///
  /// In ar, this message translates to:
  /// **'نحدّث موقعك لاستقبال طلبات المشاوير القريبة'**
  String get driverTrackingText;

  /// No description provided for @offerSeconds.
  ///
  /// In ar, this message translates to:
  /// **'{seconds} ث'**
  String offerSeconds(int seconds);

  /// No description provided for @offerPickupDistance.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د · {km} كم لعند الراكب'**
  String offerPickupDistance(int minutes, String km);

  /// No description provided for @offerTripDistance.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د · {km} كم'**
  String offerTripDistance(int minutes, String km);

  /// No description provided for @offerAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get offerAccept;

  /// No description provided for @offerDecline.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get offerDecline;

  /// No description provided for @offerLost.
  ///
  /// In ar, this message translates to:
  /// **'راح الطلب'**
  String get offerLost;

  /// No description provided for @driverHeadingToPickup.
  ///
  /// In ar, this message translates to:
  /// **'رايح لعند الراكب'**
  String get driverHeadingToPickup;

  /// No description provided for @offerNotOffered.
  ///
  /// In ar, this message translates to:
  /// **'الطلب مش معروض إلك'**
  String get offerNotOffered;

  /// No description provided for @offerDriverBusy.
  ///
  /// In ar, this message translates to:
  /// **'عندك مشوار حالي'**
  String get offerDriverBusy;

  /// No description provided for @tripOnTrip.
  ///
  /// In ar, this message translates to:
  /// **'بالطريق للوجهة'**
  String get tripOnTrip;

  /// No description provided for @tripCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المشوار'**
  String get tripCancel;

  /// No description provided for @tripCashPrompt.
  ///
  /// In ar, this message translates to:
  /// **'استلم كاش من الراكب'**
  String get tripCashPrompt;

  /// No description provided for @tripCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالراكب'**
  String get tripCall;

  /// No description provided for @tripNavigate.
  ///
  /// In ar, this message translates to:
  /// **'خرائط Google'**
  String get tripNavigate;

  /// No description provided for @tripPrice.
  ///
  /// In ar, this message translates to:
  /// **'JD {amount}'**
  String tripPrice(String amount);

  /// No description provided for @tripToPickup.
  ///
  /// In ar, this message translates to:
  /// **'رايح لعند الراكب'**
  String get tripToPickup;

  /// No description provided for @tripArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلت'**
  String get tripArrived;

  /// No description provided for @tripCompleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للوجهة؟'**
  String get tripCompleteConfirm;

  /// No description provided for @tripCashCollected.
  ///
  /// In ar, this message translates to:
  /// **'استلمت المبلغ'**
  String get tripCashCollected;

  /// No description provided for @tripComplete.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء المشوار'**
  String get tripComplete;

  /// No description provided for @tripWaitingTime.
  ///
  /// In ar, this message translates to:
  /// **'بتستنى من {time}'**
  String tripWaitingTime(String time);

  /// No description provided for @tripRedispatched.
  ///
  /// In ar, this message translates to:
  /// **'المشوار راح لسائق ثاني'**
  String get tripRedispatched;

  /// No description provided for @tripCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء المشوار'**
  String get tripCancelled;

  /// No description provided for @tripNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get tripNo;

  /// No description provided for @tripRating.
  ///
  /// In ar, this message translates to:
  /// **'{rating}'**
  String tripRating(String rating);

  /// No description provided for @tripCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'متأكد؟ رح يروح المشوار لسائق ثاني'**
  String get tripCancelConfirm;

  /// No description provided for @tripMore.
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية'**
  String get tripMore;

  /// No description provided for @tripWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الراكب'**
  String get tripWaiting;

  /// No description provided for @tripTooFar.
  ///
  /// In ar, this message translates to:
  /// **'لازم تكون قريب من نقطة الانطلاق'**
  String get tripTooFar;

  /// No description provided for @tripStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المشوار'**
  String get tripStart;

  /// No description provided for @riderEta.
  ///
  /// In ar, this message translates to:
  /// **'السائق بيوصل خلال {minutes} د'**
  String riderEta(int minutes);

  /// No description provided for @riderArrived.
  ///
  /// In ar, this message translates to:
  /// **'السائق وصل — هو بانتظارك'**
  String get riderArrived;

  /// No description provided for @riderArrival.
  ///
  /// In ar, this message translates to:
  /// **'بتوصل الساعة {time}'**
  String riderArrival(String time);

  /// No description provided for @riderWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظارك منذ {minutes} د'**
  String riderWaiting(int minutes);

  /// No description provided for @riderRedispatched.
  ///
  /// In ar, this message translates to:
  /// **'السائق لغى، بندوّر على سائق ثاني'**
  String get riderRedispatched;

  /// No description provided for @riderCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'متأكد بدك تلغي المشوار؟ السائق بالطريق'**
  String get riderCancelConfirm;

  /// No description provided for @riderContinue.
  ///
  /// In ar, this message translates to:
  /// **'لا، كمّل'**
  String get riderContinue;

  /// No description provided for @riderCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get riderCall;

  /// No description provided for @riderShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get riderShare;

  /// No description provided for @riderSafety.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get riderSafety;

  /// No description provided for @riderRating.
  ///
  /// In ar, this message translates to:
  /// **'★ {rating}'**
  String riderRating(String rating);

  /// No description provided for @riderVehicle.
  ///
  /// In ar, this message translates to:
  /// **'{make} {model} · {color}'**
  String riderVehicle(String make, String model, String color);

  /// No description provided for @riderCash.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get riderCash;

  /// No description provided for @riderCashNote.
  ///
  /// In ar, this message translates to:
  /// **'ادفع للسائق كاش'**
  String get riderCashNote;

  /// No description provided for @riderCompleted.
  ///
  /// In ar, this message translates to:
  /// **'وصلت!'**
  String get riderCompleted;

  /// No description provided for @riderDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get riderDone;

  /// No description provided for @riderRecenter.
  ///
  /// In ar, this message translates to:
  /// **'رجّع الخريطة'**
  String get riderRecenter;

  /// No description provided for @riderCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المشوار'**
  String get riderCancel;

  /// No description provided for @ratingRiderTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كان مشوارك مع {name}؟'**
  String ratingRiderTitle(String name);

  /// No description provided for @ratingDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم {name}'**
  String ratingDriverTitle(String name);

  /// No description provided for @ratingComment.
  ///
  /// In ar, this message translates to:
  /// **'بدك تضيف ملاحظة؟'**
  String get ratingComment;

  /// No description provided for @ratingSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get ratingSubmit;

  /// No description provided for @ratingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get ratingSkip;

  /// No description provided for @ratingStars.
  ///
  /// In ar, this message translates to:
  /// **'{count} من 5'**
  String ratingStars(int count);

  /// No description provided for @ratingTagSafeDriving.
  ///
  /// In ar, this message translates to:
  /// **'قيادة آمنة'**
  String get ratingTagSafeDriving;

  /// No description provided for @ratingTagCleanCar.
  ///
  /// In ar, this message translates to:
  /// **'سيارة نظيفة'**
  String get ratingTagCleanCar;

  /// No description provided for @ratingTagFriendly.
  ///
  /// In ar, this message translates to:
  /// **'لطيف'**
  String get ratingTagFriendly;

  /// No description provided for @ratingTagKnowsRoute.
  ///
  /// In ar, this message translates to:
  /// **'بعرف الطريق'**
  String get ratingTagKnowsRoute;

  /// No description provided for @ratingTagLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get ratingTagLate;

  /// No description provided for @ratingTagFastDriving.
  ///
  /// In ar, this message translates to:
  /// **'قيادة سريعة'**
  String get ratingTagFastDriving;

  /// No description provided for @ratingTagDirtyCar.
  ///
  /// In ar, this message translates to:
  /// **'سيارة مش نظيفة'**
  String get ratingTagDirtyCar;

  /// No description provided for @ratingTagLongerRoute.
  ///
  /// In ar, this message translates to:
  /// **'طريق أطول'**
  String get ratingTagLongerRoute;

  /// No description provided for @ratingTagOnTime.
  ///
  /// In ar, this message translates to:
  /// **'على الموعد'**
  String get ratingTagOnTime;

  /// No description provided for @ratingTagRespectful.
  ///
  /// In ar, this message translates to:
  /// **'محترم'**
  String get ratingTagRespectful;

  /// No description provided for @ratingTagRude.
  ///
  /// In ar, this message translates to:
  /// **'غير محترم'**
  String get ratingTagRude;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
