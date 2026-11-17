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

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get navAccount;

  /// No description provided for @historyTitle.
  ///
  /// In ar, this message translates to:
  /// **'النشاط'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك مشاوير لسا'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'مشاويرك السابقة رح تظهر هون بعد أول مشوار.'**
  String get historyEmptyBody;

  /// No description provided for @historyCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get historyCancelled;

  /// No description provided for @historyNoDrivers.
  ///
  /// In ar, this message translates to:
  /// **'ما توفر سائقين'**
  String get historyNoDrivers;

  /// No description provided for @historyStatusSuffix.
  ///
  /// In ar, this message translates to:
  /// **' · {status}'**
  String historyStatusSuffix(String status);

  /// No description provided for @historyRoute.
  ///
  /// In ar, this message translates to:
  /// **'{pickup} ← {dropoff}'**
  String historyRoute(String pickup, String dropoff);

  /// No description provided for @receiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة المشوار'**
  String get receiptTitle;

  /// No description provided for @receiptFare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة'**
  String get receiptFare;

  /// No description provided for @receiptPayment.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get receiptPayment;

  /// No description provided for @receiptTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get receiptTotal;

  /// No description provided for @receiptYourRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك'**
  String get receiptYourRating;

  /// No description provided for @receiptStars.
  ///
  /// In ar, this message translates to:
  /// **'{stars} نجوم'**
  String receiptStars(int stars);

  /// No description provided for @receiptVehicle.
  ///
  /// In ar, this message translates to:
  /// **'{make} {model} · {color}'**
  String receiptVehicle(String make, String model, String color);

  /// No description provided for @receiptRebook.
  ///
  /// In ar, this message translates to:
  /// **'اطلب نفس المشوار'**
  String get receiptRebook;

  /// No description provided for @earningsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get earningsTitle;

  /// No description provided for @earningsTrips.
  ///
  /// In ar, this message translates to:
  /// **'{count} مشاوير'**
  String earningsTrips(int count);

  /// No description provided for @earningsDayTrips.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير هذا اليوم'**
  String get earningsDayTrips;

  /// No description provided for @earningsNoTrips.
  ///
  /// In ar, this message translates to:
  /// **'ما في مشاوير بهذا اليوم'**
  String get earningsNoTrips;

  /// No description provided for @earningsBarLabel.
  ///
  /// In ar, this message translates to:
  /// **'{day}، JD {amount}'**
  String earningsBarLabel(String day, String amount);

  /// No description provided for @accountProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get accountProfile;

  /// No description provided for @accountLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get accountLanguage;

  /// No description provided for @accountAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get accountAppearance;

  /// No description provided for @accountSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get accountSystem;

  /// No description provided for @accountLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get accountLight;

  /// No description provided for @accountDark.
  ///
  /// In ar, this message translates to:
  /// **'غامق'**
  String get accountDark;

  /// No description provided for @accountDrive.
  ///
  /// In ar, this message translates to:
  /// **'اشتغل سائق معنا'**
  String get accountDrive;

  /// No description provided for @accountRide.
  ///
  /// In ar, this message translates to:
  /// **'التبديل لوضع الراكب'**
  String get accountRide;

  /// No description provided for @accountVehicle.
  ///
  /// In ar, this message translates to:
  /// **'السيارة'**
  String get accountVehicle;

  /// No description provided for @accountTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get accountTerms;

  /// No description provided for @accountPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get accountPrivacy;

  /// No description provided for @accountAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get accountAbout;

  /// No description provided for @accountSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get accountSave;

  /// No description provided for @accountCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get accountCancel;

  /// No description provided for @accountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get accountConfirm;

  /// No description provided for @accountSwitchConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بدك تغيّر وضع الحساب؟'**
  String get accountSwitchConfirm;

  /// No description provided for @accountSignOutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بدك تسجّل الخروج؟'**
  String get accountSignOutConfirm;

  /// No description provided for @accountDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get accountDelete;

  /// No description provided for @accountDeleteWarning.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائي، وما بتقدر ترجّعه. رح نحذف ملفك وبيانات سيارتك، ونحتفظ بسجلات المشاوير بدون اسمك ورقمك.'**
  String get accountDeleteWarning;

  /// No description provided for @accountDeletePrompt.
  ///
  /// In ar, this message translates to:
  /// **'اكتب حذف للتأكيد'**
  String get accountDeletePrompt;

  /// No description provided for @accountDeleteWord.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get accountDeleteWord;

  /// No description provided for @accountBusy.
  ///
  /// In ar, this message translates to:
  /// **'خلّص المشوار الحالي أول'**
  String get accountBusy;

  /// No description provided for @accountName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get accountName;

  /// No description provided for @accountNameError.
  ///
  /// In ar, this message translates to:
  /// **'الاسم لازم يكون من حرفين لـ ٤٠ حرف'**
  String get accountNameError;

  /// No description provided for @accountVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get accountVersion;

  /// No description provided for @accountArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get accountArabic;

  /// No description provided for @accountEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get accountEnglish;

  /// No description provided for @adminOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get adminOverview;

  /// No description provided for @adminDrivers.
  ///
  /// In ar, this message translates to:
  /// **'السائقين'**
  String get adminDrivers;

  /// No description provided for @adminRides.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير'**
  String get adminRides;

  /// No description provided for @adminMap.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة المباشرة'**
  String get adminMap;

  /// No description provided for @adminPricing.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار'**
  String get adminPricing;

  /// No description provided for @adminSignIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول الأدمن'**
  String get adminSignIn;

  /// No description provided for @adminEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get adminEmail;

  /// No description provided for @adminPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get adminPassword;

  /// No description provided for @adminDenied.
  ///
  /// In ar, this message translates to:
  /// **'هاد الحساب مش أدمن'**
  String get adminDenied;

  /// No description provided for @adminSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get adminSignOut;

  /// No description provided for @adminLargeScreen.
  ///
  /// In ar, this message translates to:
  /// **'افتح من شاشة أكبر'**
  String get adminLargeScreen;

  /// No description provided for @adminError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تنفيذ الطلب. حاول مرة ثانية.'**
  String get adminError;

  /// No description provided for @adminRetry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة ثانية'**
  String get adminRetry;

  /// No description provided for @adminEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما في نتائج'**
  String get adminEmpty;

  /// No description provided for @adminOnline.
  ///
  /// In ar, this message translates to:
  /// **'السائقين المتصلين'**
  String get adminOnline;

  /// No description provided for @adminActive.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير الفعّالة'**
  String get adminActive;

  /// No description provided for @adminTodayRides.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير اليوم'**
  String get adminTodayRides;

  /// No description provided for @adminPendingApplications.
  ///
  /// In ar, this message translates to:
  /// **'طلبات بانتظار المراجعة'**
  String get adminPendingApplications;

  /// No description provided for @adminLatest.
  ///
  /// In ar, this message translates to:
  /// **'آخر 10 مشاوير'**
  String get adminLatest;

  /// No description provided for @adminPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get adminPending;

  /// No description provided for @adminApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبولين'**
  String get adminApproved;

  /// No description provided for @adminSuspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوفين'**
  String get adminSuspended;

  /// No description provided for @adminRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضين'**
  String get adminRejected;

  /// No description provided for @adminSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم، الجوال أو اللوحة'**
  String get adminSearch;

  /// No description provided for @adminName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get adminName;

  /// No description provided for @adminPhone.
  ///
  /// In ar, this message translates to:
  /// **'الجوال'**
  String get adminPhone;

  /// No description provided for @adminVehicle.
  ///
  /// In ar, this message translates to:
  /// **'السيارة'**
  String get adminVehicle;

  /// No description provided for @adminPlate.
  ///
  /// In ar, this message translates to:
  /// **'اللوحة'**
  String get adminPlate;

  /// No description provided for @adminStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get adminStatus;

  /// No description provided for @adminRating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get adminRating;

  /// No description provided for @adminApplied.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التقديم'**
  String get adminApplied;

  /// No description provided for @adminPrevious.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get adminPrevious;

  /// No description provided for @adminNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get adminNext;

  /// No description provided for @adminTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get adminTime;

  /// No description provided for @adminRider.
  ///
  /// In ar, this message translates to:
  /// **'الراكب'**
  String get adminRider;

  /// No description provided for @adminDriver.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get adminDriver;

  /// No description provided for @adminRoute.
  ///
  /// In ar, this message translates to:
  /// **'الانطلاق ← الوجهة'**
  String get adminRoute;

  /// No description provided for @adminFare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة'**
  String get adminFare;

  /// No description provided for @adminAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get adminAll;

  /// No description provided for @adminSearching.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث'**
  String get adminSearching;

  /// No description provided for @adminAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get adminAccepted;

  /// No description provided for @adminArriving.
  ///
  /// In ar, this message translates to:
  /// **'السائق بالطريق'**
  String get adminArriving;

  /// No description provided for @adminArrived.
  ///
  /// In ar, this message translates to:
  /// **'السائق وصل'**
  String get adminArrived;

  /// No description provided for @adminInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري المشوار'**
  String get adminInProgress;

  /// No description provided for @adminCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get adminCompleted;

  /// No description provided for @adminCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get adminCancelled;

  /// No description provided for @adminNoDrivers.
  ///
  /// In ar, this message translates to:
  /// **'ما في سائقين'**
  String get adminNoDrivers;

  /// No description provided for @adminToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get adminToday;

  /// No description provided for @adminWeek.
  ///
  /// In ar, this message translates to:
  /// **'7 أيام'**
  String get adminWeek;

  /// No description provided for @adminCustom.
  ///
  /// In ar, this message translates to:
  /// **'فترة مخصصة'**
  String get adminCustom;

  /// No description provided for @adminApprove.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get adminApprove;

  /// No description provided for @adminReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get adminReject;

  /// No description provided for @adminSuspend.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get adminSuspend;

  /// No description provided for @adminReactivate.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تفعيل'**
  String get adminReactivate;

  /// No description provided for @adminReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب (حتى 200 حرف)'**
  String get adminReason;

  /// No description provided for @adminConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get adminConfirm;

  /// No description provided for @adminDismiss.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get adminDismiss;

  /// No description provided for @adminCancelRide.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المشوار'**
  String get adminCancelRide;

  /// No description provided for @adminLicense.
  ///
  /// In ar, this message translates to:
  /// **'صورة الرخصة'**
  String get adminLicense;

  /// No description provided for @adminLicenseMissing.
  ///
  /// In ar, this message translates to:
  /// **'ما في صورة رخصة مرفوعة'**
  String get adminLicenseMissing;

  /// No description provided for @adminHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get adminHistory;

  /// No description provided for @adminCompletedTrips.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير المكتملة'**
  String get adminCompletedTrips;

  /// No description provided for @adminCancellations.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاءات'**
  String get adminCancellations;

  /// No description provided for @adminEstimated.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة التقديرية'**
  String get adminEstimated;

  /// No description provided for @adminFinal.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة النهائية'**
  String get adminFinal;

  /// No description provided for @adminTimeline.
  ///
  /// In ar, this message translates to:
  /// **'التسلسل الزمني'**
  String get adminTimeline;

  /// No description provided for @adminRiderRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الراكب'**
  String get adminRiderRating;

  /// No description provided for @adminDriverRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم السائق'**
  String get adminDriverRating;

  /// No description provided for @adminClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get adminClose;

  /// No description provided for @adminMapFallback.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح الخريطة غير متوفر. مواقع السائقين معروضة بالقائمة.'**
  String get adminMapFallback;

  /// No description provided for @adminMapFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الخريطة. مواقع السائقين معروضة بالقائمة.'**
  String get adminMapFailed;

  /// No description provided for @adminFree.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get adminFree;

  /// No description provided for @adminBusy.
  ///
  /// In ar, this message translates to:
  /// **'بمشوار'**
  String get adminBusy;

  /// No description provided for @adminCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'الإحداثيات'**
  String get adminCoordinates;

  /// No description provided for @adminEconomy.
  ///
  /// In ar, this message translates to:
  /// **'اقتصادي'**
  String get adminEconomy;

  /// No description provided for @adminComfort.
  ///
  /// In ar, this message translates to:
  /// **'مريح'**
  String get adminComfort;

  /// No description provided for @adminVan.
  ///
  /// In ar, this message translates to:
  /// **'فان'**
  String get adminVan;

  /// No description provided for @adminBase.
  ///
  /// In ar, this message translates to:
  /// **'الأساس'**
  String get adminBase;

  /// No description provided for @adminPerKm.
  ///
  /// In ar, this message translates to:
  /// **'لكل كم'**
  String get adminPerKm;

  /// No description provided for @adminPerMin.
  ///
  /// In ar, this message translates to:
  /// **'لكل دقيقة'**
  String get adminPerMin;

  /// No description provided for @adminMinimum.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get adminMinimum;

  /// No description provided for @adminPreview.
  ///
  /// In ar, this message translates to:
  /// **'تقدير 10 كم / 20 دقيقة'**
  String get adminPreview;

  /// No description provided for @adminSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get adminSave;

  /// No description provided for @adminRateInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل قيمة أكبر من 0 وحتى 50، بحد أقصى 3 منازل عشرية'**
  String get adminRateInvalid;

  /// No description provided for @adminUpdatedBy.
  ///
  /// In ar, this message translates to:
  /// **'آخر تعديل بواسطة'**
  String get adminUpdatedBy;

  /// No description provided for @adminUpdatedAt.
  ///
  /// In ar, this message translates to:
  /// **'آخر تعديل بتاريخ'**
  String get adminUpdatedAt;

  /// No description provided for @adminSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get adminSaved;

  /// No description provided for @adminCurrency.
  ///
  /// In ar, this message translates to:
  /// **'د.أ'**
  String get adminCurrency;

  /// No description provided for @adminUnknown.
  ///
  /// In ar, this message translates to:
  /// **'—'**
  String get adminUnknown;

  /// No description provided for @adminLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get adminLanguage;
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
