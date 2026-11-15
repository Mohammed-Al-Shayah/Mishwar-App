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
