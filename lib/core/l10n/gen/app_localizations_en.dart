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

  @override
  String get driverStart => 'Start';

  @override
  String get driverOffline => 'You are offline';

  @override
  String get driverOfflineHint => 'Go online to receive ride requests';

  @override
  String get driverOnline => 'You are online';

  @override
  String get driverOnlineHint => 'Looking for nearby requests...';

  @override
  String get driverStop => 'Stop';

  @override
  String get driverStopConfirm => 'Stop receiving ride requests?';

  @override
  String get driverKeepOnline => 'Stay online';

  @override
  String get driverEarnings => 'Today\'s earnings';

  @override
  String get driverEarningsAmount => 'JD 0.00';

  @override
  String get driverTrackingTitle => 'Mishwar - you are online';

  @override
  String get driverTrackingText =>
      'Updating your location to receive nearby ride requests';

  @override
  String offerSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String offerPickupDistance(int minutes, String km) {
    return '$minutes min · $km km to rider';
  }

  @override
  String offerTripDistance(int minutes, String km) {
    return '$minutes min · $km km';
  }

  @override
  String get offerAccept => 'Accept';

  @override
  String get offerDecline => 'Decline';

  @override
  String get offerLost => 'Offer gone';

  @override
  String get driverHeadingToPickup => 'On the way to pickup';

  @override
  String get offerNotOffered => 'This ride is no longer offered to you';

  @override
  String get offerDriverBusy => 'You already have a ride';

  @override
  String get tripOnTrip => 'On the way to the destination';

  @override
  String get tripCancel => 'Cancel trip';

  @override
  String get tripCashPrompt => 'Collect cash from the rider';

  @override
  String get tripCall => 'Call rider';

  @override
  String get tripNavigate => 'Google Maps';

  @override
  String tripPrice(String amount) {
    return 'JD $amount';
  }

  @override
  String get tripToPickup => 'Heading to the rider';

  @override
  String get tripArrived => 'I have arrived';

  @override
  String get tripCompleteConfirm => 'Reached the destination?';

  @override
  String get tripCashCollected => 'Cash collected';

  @override
  String get tripComplete => 'End trip';

  @override
  String tripWaitingTime(String time) {
    return 'Waiting for $time';
  }

  @override
  String get tripRedispatched => 'The trip is going to another driver';

  @override
  String get tripCancelled => 'This trip was cancelled';

  @override
  String get tripNo => 'No';

  @override
  String tripRating(String rating) {
    return '$rating';
  }

  @override
  String get tripCancelConfirm =>
      'Are you sure? This trip will go to another driver';

  @override
  String get tripMore => 'More options';

  @override
  String get tripWaiting => 'Waiting for the rider';

  @override
  String get tripTooFar => 'You need to be near the pickup point';

  @override
  String get tripStart => 'Start trip';

  @override
  String riderEta(int minutes) {
    return 'Driver arrives in $minutes min';
  }

  @override
  String get riderArrived => 'Your driver has arrived ? waiting for you';

  @override
  String riderArrival(String time) {
    return 'Arriving at $time';
  }

  @override
  String riderWaiting(int minutes) {
    return 'Waiting for $minutes min';
  }

  @override
  String get riderRedispatched =>
      'Your driver cancelled. Finding another driver';

  @override
  String get riderCancelConfirm =>
      'Cancel this trip? Your driver is on the way';

  @override
  String get riderContinue => 'No, continue';

  @override
  String get riderCall => 'Call';

  @override
  String get riderShare => 'Share';

  @override
  String get riderSafety => 'Safety';

  @override
  String riderRating(String rating) {
    return '★ $rating';
  }

  @override
  String riderVehicle(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get riderCash => 'Cash';

  @override
  String get riderCashNote => 'Pay your driver in cash';

  @override
  String get riderCompleted => 'You’ve arrived!';

  @override
  String get riderDone => 'Done';

  @override
  String get riderRecenter => 'Recenter';

  @override
  String get riderCancel => 'Cancel trip';

  @override
  String ratingRiderTitle(String name) {
    return 'How was your ride with $name?';
  }

  @override
  String ratingDriverTitle(String name) {
    return 'Rate $name';
  }

  @override
  String get ratingComment => 'Want to add a note?';

  @override
  String get ratingSubmit => 'Send';

  @override
  String get ratingSkip => 'Skip';

  @override
  String ratingStars(int count) {
    return '$count out of 5';
  }

  @override
  String get ratingTagSafeDriving => 'Safe driving';

  @override
  String get ratingTagCleanCar => 'Clean car';

  @override
  String get ratingTagFriendly => 'Friendly';

  @override
  String get ratingTagKnowsRoute => 'Knows the route';

  @override
  String get ratingTagLate => 'Late';

  @override
  String get ratingTagFastDriving => 'Fast driving';

  @override
  String get ratingTagDirtyCar => 'Dirty car';

  @override
  String get ratingTagLongerRoute => 'Longer route';

  @override
  String get ratingTagOnTime => 'On time';

  @override
  String get ratingTagRespectful => 'Respectful';

  @override
  String get ratingTagRude => 'Rude';

  @override
  String get navHome => 'Home';

  @override
  String get navAccount => 'Account';

  @override
  String get historyTitle => 'Activity';

  @override
  String get historyEmptyTitle => 'No trips yet';

  @override
  String get historyEmptyBody =>
      'Your past trips will appear here after your first ride.';

  @override
  String get historyCancelled => 'Cancelled';

  @override
  String get historyNoDrivers => 'No drivers available';

  @override
  String historyStatusSuffix(String status) {
    return ' · $status';
  }

  @override
  String historyRoute(String pickup, String dropoff) {
    return '$pickup → $dropoff';
  }

  @override
  String get receiptTitle => 'Trip receipt';

  @override
  String get receiptFare => 'Fare';

  @override
  String get receiptPayment => 'Payment';

  @override
  String get receiptTotal => 'Total';

  @override
  String get receiptYourRating => 'Your rating';

  @override
  String receiptStars(int stars) {
    return '$stars stars';
  }

  @override
  String receiptVehicle(String make, String model, String color) {
    return '$make $model · $color';
  }

  @override
  String get receiptRebook => 'Request this trip again';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String earningsTrips(int count) {
    return '$count trips';
  }

  @override
  String get earningsDayTrips => 'This day\'s trips';

  @override
  String get earningsNoTrips => 'No trips on this day';

  @override
  String earningsBarLabel(String day, String amount) {
    return '$day, JD $amount';
  }

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountAppearance => 'Appearance';

  @override
  String get accountSystem => 'System';

  @override
  String get accountLight => 'Light';

  @override
  String get accountDark => 'Dark';

  @override
  String get accountDrive => 'Drive with us';

  @override
  String get accountRide => 'Switch to rider mode';

  @override
  String get accountVehicle => 'Vehicle';

  @override
  String get accountTerms => 'Terms and conditions';

  @override
  String get accountPrivacy => 'Privacy policy';

  @override
  String get accountAbout => 'About';

  @override
  String get accountSave => 'Save';

  @override
  String get accountCancel => 'Cancel';

  @override
  String get accountConfirm => 'Confirm';

  @override
  String get accountSwitchConfirm => 'Switch account mode?';

  @override
  String get accountSignOutConfirm => 'Sign out of your account?';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteWarning =>
      'Account deletion is permanent. Your profile and vehicle data will be removed. Ride records will be retained without your name or phone.';

  @override
  String get accountDeletePrompt => 'Type delete to confirm';

  @override
  String get accountDeleteWord => 'delete';

  @override
  String get accountBusy => 'Finish the current ride first';

  @override
  String get accountName => 'Name';

  @override
  String get accountNameError => 'Name must be 2-40 characters';

  @override
  String get accountVersion => 'Version';

  @override
  String get accountArabic => 'العربية';

  @override
  String get accountEnglish => 'English';

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminDrivers => 'Drivers';

  @override
  String get adminRides => 'Rides';

  @override
  String get adminMap => 'Live map';

  @override
  String get adminPricing => 'Pricing';

  @override
  String get adminSignIn => 'Admin sign in';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminDenied => 'This account is not an admin';

  @override
  String get adminSignOut => 'Sign out';

  @override
  String get adminLargeScreen => 'Open on a larger screen';

  @override
  String get adminError => 'Request failed. Please try again.';

  @override
  String get adminRetry => 'Retry';

  @override
  String get adminEmpty => 'No results';

  @override
  String get adminOnline => 'Online drivers';

  @override
  String get adminActive => 'Active rides';

  @override
  String get adminTodayRides => 'Rides today';

  @override
  String get adminPendingApplications => 'Pending applications';

  @override
  String get adminLatest => 'Latest 10 rides';

  @override
  String get adminPending => 'Pending';

  @override
  String get adminApproved => 'Approved';

  @override
  String get adminSuspended => 'Suspended';

  @override
  String get adminRejected => 'Rejected';

  @override
  String get adminSearch => 'Search name, phone or plate';

  @override
  String get adminName => 'Name';

  @override
  String get adminPhone => 'Phone';

  @override
  String get adminVehicle => 'Vehicle';

  @override
  String get adminPlate => 'Plate';

  @override
  String get adminStatus => 'Status';

  @override
  String get adminRating => 'Rating';

  @override
  String get adminApplied => 'Applied';

  @override
  String get adminPrevious => 'Previous';

  @override
  String get adminNext => 'Next';

  @override
  String get adminTime => 'Time';

  @override
  String get adminRider => 'Rider';

  @override
  String get adminDriver => 'Driver';

  @override
  String get adminRoute => 'Pickup → dropoff';

  @override
  String get adminFare => 'Fare';

  @override
  String get adminAll => 'All';

  @override
  String get adminSearching => 'Searching';

  @override
  String get adminAccepted => 'Accepted';

  @override
  String get adminArriving => 'Arriving';

  @override
  String get adminArrived => 'Arrived';

  @override
  String get adminInProgress => 'In progress';

  @override
  String get adminCompleted => 'Completed';

  @override
  String get adminCancelled => 'Cancelled';

  @override
  String get adminNoDrivers => 'No drivers';

  @override
  String get adminToday => 'Today';

  @override
  String get adminWeek => '7 days';

  @override
  String get adminCustom => 'Custom range';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminSuspend => 'Suspend';

  @override
  String get adminReactivate => 'Reactivate';

  @override
  String get adminReason => 'Reason (up to 200 characters)';

  @override
  String get adminConfirm => 'Confirm';

  @override
  String get adminDismiss => 'Back';

  @override
  String get adminCancelRide => 'Cancel ride';

  @override
  String get adminLicense => 'License photo';

  @override
  String get adminLicenseMissing => 'No license photo uploaded';

  @override
  String get adminHistory => 'History';

  @override
  String get adminCompletedTrips => 'Completed trips';

  @override
  String get adminCancellations => 'Cancellations';

  @override
  String get adminEstimated => 'Estimated fare';

  @override
  String get adminFinal => 'Final fare';

  @override
  String get adminTimeline => 'Timeline';

  @override
  String get adminRiderRating => 'Rider rating';

  @override
  String get adminDriverRating => 'Driver rating';

  @override
  String get adminClose => 'Close';

  @override
  String get adminMapFallback =>
      'Map key unavailable. Driver coordinates are shown below.';

  @override
  String get adminMapFailed =>
      'Map could not load. Driver coordinates are shown below.';

  @override
  String get adminFree => 'Free';

  @override
  String get adminBusy => 'On a ride';

  @override
  String get adminCoordinates => 'Coordinates';

  @override
  String get adminEconomy => 'Economy';

  @override
  String get adminComfort => 'Comfort';

  @override
  String get adminVan => 'Van';

  @override
  String get adminBase => 'Base';

  @override
  String get adminPerKm => 'Per km';

  @override
  String get adminPerMin => 'Per minute';

  @override
  String get adminMinimum => 'Minimum';

  @override
  String get adminPreview => 'Preview: 10 km / 20 min';

  @override
  String get adminSave => 'Save';

  @override
  String get adminRateInvalid =>
      'Enter a value above 0 and up to 50, with at most 3 decimal places';

  @override
  String get adminUpdatedBy => 'Last updated by';

  @override
  String get adminUpdatedAt => 'Last updated at';

  @override
  String get adminSaved => 'Saved';

  @override
  String get adminCurrency => 'JOD';

  @override
  String get adminUnknown => '—';

  @override
  String get adminLanguage => 'Language';

  @override
  String get savedPlaces => 'Saved places';

  @override
  String get savedPlaceHome => 'Home';

  @override
  String get savedPlaceWork => 'Work';

  @override
  String get savedPlaceOther => 'Other';

  @override
  String get savedPlaceAddHome => 'Add home';

  @override
  String get savedPlaceAddWork => 'Add work';

  @override
  String get savedPlaceTapToSet => 'Tap to set the location';

  @override
  String get savedPlaceAdd => 'Add place';

  @override
  String get savedPlaceEdit => 'Edit place';

  @override
  String get savedPlaceType => 'Type';

  @override
  String get savedPlaceName => 'Place name';

  @override
  String get savedPlaceChooseLocation => 'Choose location';

  @override
  String get savedPlaceDelete => 'Delete place';

  @override
  String savedPlaceDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get savedPlacesEmpty => 'No saved places yet';

  @override
  String get savedPlacesEmptyHint =>
      'Save home and work to get there in one tap';

  @override
  String get savedPlaceLimit => 'You reached the limit of 20 places';

  @override
  String get savedPlaceInvalid => 'Check the name and location';

  @override
  String get recentPlaces => 'Recent';

  @override
  String get scheduleTitle => 'When do you want to leave?';

  @override
  String get scheduleToday => 'Today';

  @override
  String get scheduleTomorrow => 'Tomorrow';

  @override
  String get scheduleOtherDate => 'Another date';

  @override
  String get scheduleWindow => 'Book from 30 minutes to 30 days ahead';

  @override
  String get scheduleConfirm => 'Confirm time';

  @override
  String get scheduleClear => 'Clear scheduled time';

  @override
  String get scheduleSuccess => 'Your ride is booked';

  @override
  String scheduledDeparture(String time) {
    return 'Departure time · $time';
  }

  @override
  String scheduleVehicle(String vehicle) {
    return 'Book $vehicle';
  }

  @override
  String get scheduledSection => 'Scheduled';

  @override
  String get scheduledCancelTitle => 'Cancel your scheduled ride?';

  @override
  String get scheduledCancelConfirm => 'Cancel ride';

  @override
  String get scheduledKeep => 'Keep ride';

  @override
  String get scheduledCancel => 'Cancel';

  @override
  String get tooManyScheduled =>
      'You can have up to 3 scheduled rides. Cancel one to book another.';

  @override
  String get promoAdd => 'Add promo code';

  @override
  String get promoApply => 'Apply';

  @override
  String get promoCodeLabel => 'Promo code';

  @override
  String get promoRemove => 'Remove promo code';

  @override
  String promoSelected(String code, String amount) {
    return '$code · JD $amount off';
  }

  @override
  String promoDiscount(String code, String amount) {
    return 'Discount ($code) − JD $amount';
  }

  @override
  String promoCashFootnote(String amount) {
    return 'Includes JD $amount discount';
  }

  @override
  String get promoNotFound => 'Invalid promo code';

  @override
  String get promoInactive => 'This code is inactive';

  @override
  String get promoNotStarted => 'This code is not valid yet';

  @override
  String get promoExpired => 'This code has expired';

  @override
  String get promoLimit => 'This code has reached its limit';

  @override
  String get promoUserLimit => 'You already used this code';

  @override
  String get promoFirstRide => 'This code is for your first ride only';

  @override
  String promoMinFare(String amount) {
    return 'Minimum fare for this code is JD $amount';
  }

  @override
  String get promoRateLimit => 'Too many checks. Try again shortly';

  @override
  String get adminContent => 'Content';

  @override
  String get contentBanners => 'Banners';

  @override
  String get contentAddBanner => 'Add banner';

  @override
  String get contentEditBanner => 'Edit banner';

  @override
  String get contentTitle => 'Title';

  @override
  String get contentSubtitle => 'Subtitle';

  @override
  String get contentImage => 'Image URL (https)';

  @override
  String get contentAction => 'Action';

  @override
  String get contentSearch => 'Open search';

  @override
  String get contentPromo => 'Promo code';

  @override
  String get contentUrl => 'External URL (https)';

  @override
  String get contentOrder => 'Order';

  @override
  String get contentValidUntil => 'Valid until';

  @override
  String get contentActive => 'Active';

  @override
  String get contentSave => 'Save';

  @override
  String get contentDelete => 'Delete';

  @override
  String get contentDeleteConfirm => 'Delete this banner?';

  @override
  String get contentCancel => 'Cancel';

  @override
  String get contentInvalid => 'Check this value';

  @override
  String get contentMoveUp => 'Move up';

  @override
  String get contentMoveDown => 'Move down';

  @override
  String get contentServices => 'Services';

  @override
  String get contentEnabled => 'Enabled';

  @override
  String bannerPage(int page, int total) {
    return 'Offer $page of $total';
  }

  @override
  String get contentLinkError => 'Could not open link';

  @override
  String get servicesSuggestions => 'Suggestions';

  @override
  String get servicesAll => 'See all';

  @override
  String get serviceRide => 'Ride';

  @override
  String get serviceSchedule => 'Reserve';

  @override
  String get serviceParcel => 'Parcel';

  @override
  String get serviceAirport => 'Airport';

  @override
  String get serviceSoon => 'Soon';

  @override
  String get serviceSoonMessage => 'Service coming soon';

  @override
  String get serviceRideDescription => 'Request a ride now';

  @override
  String get serviceScheduleDescription => 'Choose your departure';

  @override
  String get serviceParcelDescription => 'Send a package';

  @override
  String get serviceAirportDescription => 'Rides to and from the airport';

  @override
  String cancellationFeeWarning(String amount) {
    return 'Cancelling now costs $amount, added to your next ride.';
  }

  @override
  String freeWaitingCountdown(String time) {
    return 'Free waiting $time';
  }

  @override
  String waitingFeeRate(String amount) {
    return 'Waiting fee $amount per minute';
  }

  @override
  String waitingFeeRunning(String amount) {
    return 'Waiting fee: $amount';
  }

  @override
  String get feeWaiting => 'Waiting fee';

  @override
  String get feePreviousBalance => 'Previous cancellation fees';

  @override
  String get feeCancellation => 'Cancellation fee';

  @override
  String cancellationBalanceInfo(String amount) {
    return 'You owe $amount in cancellation fees, added to your next ride.';
  }

  @override
  String get safetyTitle => 'Safety';

  @override
  String get trustedContacts => 'Trusted contacts';

  @override
  String get contactsEmpty => 'Add people you trust';

  @override
  String get contactsExplanation =>
      'Save up to five people to send your location when you need help.';

  @override
  String get contactAdd => 'Add trusted contact';

  @override
  String get contactEdit => 'Edit trusted contact';

  @override
  String get contactDelete => 'Delete trusted contact';

  @override
  String contactDeleteConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Jordanian mobile number';

  @override
  String get contactInvalid =>
      'Enter a name of 1–40 characters and a valid Jordanian mobile number.';

  @override
  String get contactsLimit => 'You can add up to five trusted contacts.';

  @override
  String get emergencySettings => 'Emergency settings';

  @override
  String get emergencyFootnote => 'The emergency number in Jordan is 911';

  @override
  String get safetyToolkit => 'Safety tools';

  @override
  String get emergencyCall => 'Call emergency services (911)';

  @override
  String get emergencyConfirm => 'Call emergency services on 911?';

  @override
  String get safetySms => 'Send my location to trusted contacts';

  @override
  String get safetyNoContacts => 'Add trusted contacts in Safety';

  @override
  String get safetyShare => 'Share trip details';

  @override
  String shareTripText(String driver, String url) {
    return 'Follow my trip with $driver on Mishwar: $url';
  }

  @override
  String safetySmsBody(
    String driver,
    String car,
    String plate,
    String coordinates,
  ) {
    return 'I am on a trip with $driver ($car $plate). My location: https://maps.google.com/?q=$coordinates';
  }

  @override
  String safetyDriverSmsBody(String coordinates) {
    return 'My location: https://maps.google.com/?q=$coordinates';
  }

  @override
  String get activityUpcoming => 'Upcoming';

  @override
  String get activityPast => 'Past';

  @override
  String get activityUpcomingEmpty =>
      'No upcoming rides. Schedule a ride from Home.';

  @override
  String get receiptReport => 'Report a problem';

  @override
  String get receiptShare => 'Share receipt';

  @override
  String get receiptCancelledRider => 'Cancelled by the rider';

  @override
  String get receiptCancelledDriver => 'Cancelled by the driver';

  @override
  String get receiptCancelledSystem => 'Cancelled by the system';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportNew => 'New help request';

  @override
  String get supportEmpty => 'No support requests yet';

  @override
  String get supportOpen => 'Open';

  @override
  String get supportInProgress => 'In progress';

  @override
  String get supportClosed => 'Closed';

  @override
  String get supportLostItem => 'Lost item';

  @override
  String get supportFare => 'Fare';

  @override
  String get supportSafety => 'Safety';

  @override
  String get supportOther => 'Other';

  @override
  String get supportMessage => 'Your message';

  @override
  String get supportSend => 'Send';

  @override
  String get supportClosedNote =>
      'This request is closed. You can open a new help request.';

  @override
  String get supportMessageInvalid => 'Write a message of 1–1000 characters.';

  @override
  String get supportLimit =>
      'You have 5 active requests. Wait for one to close before opening another.';

  @override
  String get supportUnread => 'New support reply';

  @override
  String get supportRole => 'Role';

  @override
  String get supportCategory => 'Category';

  @override
  String get supportRide => 'Ride';

  @override
  String get supportLastMessage => 'Last message';

  @override
  String get supportUser => 'User';

  @override
  String get supportStatus => 'Status';

  @override
  String get supportUserMessage => 'You';

  @override
  String get supportAdminMessage => 'Support team';

  @override
  String get supportRider => 'Rider';

  @override
  String get supportDriver => 'Driver';

  @override
  String get parcelTitle => 'Parcel delivery';

  @override
  String get parcelRecipient => 'Recipient name';

  @override
  String get parcelDescription => 'What\'s in the parcel?';

  @override
  String get parcelPhoto => 'Parcel photo';

  @override
  String get parcelPhotoOptional =>
      'Optional — helps the driver identify the parcel';

  @override
  String get parcelPhotoUploaded => 'Photo ready, tap to change it';

  @override
  String get parcelInvalid =>
      'Check the recipient name, mobile number and parcel description';

  @override
  String get parcelContinue => 'Continue to destination';

  @override
  String get parcelRequest => 'Request delivery';

  @override
  String parcelCode(String code) {
    return 'Delivery code: $code — give it to the recipient';
  }

  @override
  String get parcelSendCode => 'Send code to recipient';

  @override
  String parcelSms(String code) {
    return 'Mishwar: your parcel delivery code is $code';
  }

  @override
  String get parcelDeliver => 'Deliver parcel';

  @override
  String get parcelEnterCode =>
      'Ask the recipient for their 4-digit delivery code';

  @override
  String get parcelBadCode => 'That code isn\'t right. Try again';

  @override
  String get parcelCodeLocked =>
      'You\'ve reached 5 attempts. Contact support to complete delivery';

  @override
  String get parcelSupport => 'Contact support';

  @override
  String get parcelServiceDisabled =>
      'Parcel delivery is unavailable right now. Try again later';

  @override
  String get airportTo => 'To the airport';

  @override
  String get airportFrom => 'From the airport';

  @override
  String get airportName => 'Queen Alia International Airport';

  @override
  String get airportPickup => 'Choose a pickup point';

  @override
  String get airportFlightNumber => 'Flight number (optional)';

  @override
  String get airportFlightHint => 'RJ 182';

  @override
  String get airportFlightInvalid => 'Check your flight number, e.g. RJ 182';

  @override
  String get airportUnavailable =>
      'Airport service is unavailable. Please try again later.';

  @override
  String get airportContinue => 'Continue';

  @override
  String get airportFixedFare => 'Fixed airport fare';

  @override
  String get airportReceipt => 'Airport ride · Fixed fare';

  @override
  String get pickupTitle => 'Confirm pickup point';

  @override
  String get pickupHint => 'Move the map to set your exact pickup point';

  @override
  String get pickupConfirm => 'Confirm pickup';

  @override
  String get pickupFarWarning => 'Pickup point is far from your location';

  @override
  String get pickupEdit => 'Edit pickup point';

  @override
  String get pickupGeneric => 'Pickup point';
}
