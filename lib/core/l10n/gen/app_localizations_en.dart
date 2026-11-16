// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get planRide => 'Plan your ride';

  @override
  String get currentLocation => 'Your current location';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchPlacesHint => 'Enter a place or street name';

  @override
  String noPlacesFound(String query) {
    return 'No results for “$query”';
  }

  @override
  String get chooseRide => 'Choose a ride';

  @override
  String get whereTo => 'Where to?';

  @override
  String get scheduleLater => 'Later';

  @override
  String get mapMobileOnly => 'The map is available in the mobile app';

  @override
  String get locationPermissionHint =>
      'Allow location to find your pickup point.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get openSettings => 'Open settings';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get locationForeverHint =>
      'Enable location permission in app settings.';

  @override
  String get locationServiceHint =>
      'Turn on location services to find your position.';

  @override
  String get locationTimeout => 'Finding your location timed out. Try again.';

  @override
  String get locationError => 'Unable to find your location. Try again.';

  @override
  String get recenterMap => 'My location';

  @override
  String get openMenu => 'Menu';

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

  @override
  String get driverRegisterTitle => 'Register your vehicle';

  @override
  String get driverReviewTime => 'We review your application within 24 hours';

  @override
  String get vehicleTypeTitle => 'Vehicle type';

  @override
  String get vehicleEconomy => 'Economy';

  @override
  String get vehicleComfort => 'Comfort';

  @override
  String get vehicleVan => 'Family';

  @override
  String get vehicleEconomyDescription => '4 passengers, lower fares';

  @override
  String get vehicleComfortDescription => '4 passengers, a newer car';

  @override
  String get vehicleVanDescription => 'Up to 6 passengers';

  @override
  String get vehicleDetailsTitle => 'Vehicle details';

  @override
  String get vehicleMake => 'Make';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleColor => 'Color';

  @override
  String get vehiclePlate => 'License plate';

  @override
  String get vehiclePlateHint => '12-34567';

  @override
  String get licenseTitle => 'Driving license';

  @override
  String get photoChoose => 'Add license photo';

  @override
  String get photoChange => 'Change';

  @override
  String get photoSaved => 'Your license photo is saved';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoGallery => 'Photo library';

  @override
  String get driverSubmit => 'Submit application';

  @override
  String get driverPendingTitle => 'Your application is under review';

  @override
  String get driverPendingBody =>
      'We review your vehicle details and license within 24 hours. Your status will update here.';

  @override
  String get driverRejectedTitle => 'Your application was rejected';

  @override
  String get driverRejectedBody =>
      'Review your details, make changes and resubmit.';

  @override
  String get driverSuspendedTitle => 'Your account is temporarily suspended';

  @override
  String get driverSuspendedBody =>
      'Contact support for help with your account.';

  @override
  String get driverResubmit => 'Edit and resubmit';

  @override
  String get errorVehicleLength => 'Enter between 2 and 30 characters.';

  @override
  String get errorPlateFormat => 'Enter a valid plate, such as 12-34567.';

  @override
  String get errorPhotoRequired => 'Add a photo of your driving license.';

  @override
  String vehicleSummary(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get economyTagline => 'Affordable rides';

  @override
  String get comfortTagline => 'Newer cars and more space';

  @override
  String get vanTagline => 'Up to 6 passengers';

  @override
  String get cashPayment => 'Cash';

  @override
  String get confirmRetry => 'Try again';

  @override
  String chooseVehicle(String vehicle) {
    return 'Choose $vehicle';
  }

  @override
  String tripPill(int minutes, String destination) {
    return '$minutes min · $destination';
  }

  @override
  String arrivalDuration(String time, int minutes) {
    return '$time · $minutes minutes';
  }

  @override
  String fareJod(String amount) {
    return 'JD $amount';
  }

  @override
  String get searchingTitle => 'Looking for a nearby driver…';

  @override
  String get searchingQuick => 'Usually takes less than a minute';

  @override
  String searchingVehicle(String vehicleName) {
    return 'Finding you a $vehicleName';
  }

  @override
  String get searchingNearby => 'Contacting nearby drivers';

  @override
  String get rideCancel => 'Cancel request';

  @override
  String get rideCancelTitle => 'Cancel your request?';

  @override
  String get rideKeepSearching => 'Keep looking';

  @override
  String get rideNoDrivers => 'No nearby drivers found';

  @override
  String get rideTryAgain => 'Try again';

  @override
  String get rideBack => 'Back';

  @override
  String get rideAccepted => 'We found a driver!';
}
