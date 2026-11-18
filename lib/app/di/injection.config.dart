// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mishwar/core/di/register_module.dart' as _i398;
import 'package:mishwar/core/settings/locale_cubit.dart' as _i159;
import 'package:mishwar/core/settings/theme_mode_cubit.dart' as _i390;
import 'package:mishwar/features/admin/data/admin_remote_data_source.dart'
    as _i409;
import 'package:mishwar/features/admin/data/admin_repository_impl.dart'
    as _i485;
import 'package:mishwar/features/admin/domain/admin_repository.dart' as _i1005;
import 'package:mishwar/features/admin/domain/admin_usecases.dart' as _i180;
import 'package:mishwar/features/admin/presentation/admin_cubit.dart' as _i630;
import 'package:mishwar/features/common/account/data/account_repository_impl.dart'
    as _i42;
import 'package:mishwar/features/common/account/domain/account_repository.dart'
    as _i100;
import 'package:mishwar/features/common/account/domain/delete_account.dart'
    as _i776;
import 'package:mishwar/features/common/account/domain/switch_role.dart'
    as _i939;
import 'package:mishwar/features/common/account/domain/update_name.dart'
    as _i139;
import 'package:mishwar/features/common/account/presentation/account_cubit.dart'
    as _i777;
import 'package:mishwar/features/common/auth/data/datasources/auth_remote_data_source.dart'
    as _i243;
import 'package:mishwar/features/common/auth/data/repositories/auth_repository_impl.dart'
    as _i15;
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart'
    as _i858;
import 'package:mishwar/features/common/auth/domain/repositories/auth_repository.dart'
    as _i290;
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart'
    as _i563;
import 'package:mishwar/features/common/auth/domain/usecases/sign_out.dart'
    as _i442;
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart'
    as _i454;
import 'package:mishwar/features/common/auth/domain/usecases/watch_auth_state.dart'
    as _i584;
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart'
    as _i104;
import 'package:mishwar/features/common/auth/presentation/cubit/name_cubit.dart'
    as _i693;
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart'
    as _i267;
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart'
    as _i964;
import 'package:mishwar/features/common/auth/presentation/cubit/role_cubit.dart'
    as _i520;
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart'
    as _i838;
import 'package:mishwar/features/common/location/data/datasources/geolocator_client.dart'
    as _i766;
import 'package:mishwar/features/common/location/data/datasources/location_data_source.dart'
    as _i101;
import 'package:mishwar/features/common/location/data/repositories/location_repository_impl.dart'
    as _i578;
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart'
    as _i300;
import 'package:mishwar/features/common/location/domain/usecases/check_location_permission.dart'
    as _i524;
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart'
    as _i107;
import 'package:mishwar/features/common/location/domain/usecases/open_app_settings.dart'
    as _i916;
import 'package:mishwar/features/common/location/domain/usecases/open_location_settings.dart'
    as _i682;
import 'package:mishwar/features/common/location/domain/usecases/request_location_permission.dart'
    as _i605;
import 'package:mishwar/features/common/location/domain/usecases/watch_position.dart'
    as _i365;
import 'package:mishwar/features/common/notifications/domain/push_repository.dart'
    as _i43;
import 'package:mishwar/features/common/notifications/domain/push_token_sync.dart'
    as _i768;
import 'package:mishwar/features/common/notifications/domain/usecases/register_push_token.dart'
    as _i126;
import 'package:mishwar/features/common/notifications/domain/usecases/unregister_push_token.dart'
    as _i282;
import 'package:mishwar/features/common/notifications/domain/usecases/watch_push_routes.dart'
    as _i897;
import 'package:mishwar/features/common/places/data/datasources/places_remote_data_source.dart'
    as _i29;
import 'package:mishwar/features/common/places/data/repositories/places_repository_impl.dart'
    as _i692;
import 'package:mishwar/features/common/places/domain/repositories/places_repository.dart'
    as _i1040;
import 'package:mishwar/features/common/places/domain/usecases/get_place_details.dart'
    as _i393;
import 'package:mishwar/features/common/places/domain/usecases/search_places.dart'
    as _i62;
import 'package:mishwar/features/common/pricing/domain/fare_calculator.dart'
    as _i304;
import 'package:mishwar/features/common/promos/data/promo_remote_data_source.dart'
    as _i585;
import 'package:mishwar/features/common/promos/data/promo_repository_impl.dart'
    as _i587;
import 'package:mishwar/features/common/promos/domain/promo_repository.dart'
    as _i285;
import 'package:mishwar/features/common/promos/domain/validate_promo.dart'
    as _i164;
import 'package:mishwar/features/common/rating/domain/rate_ride.dart' as _i899;
import 'package:mishwar/features/common/rating/domain/rating_tag.dart' as _i176;
import 'package:mishwar/features/common/rating/domain/skip_rating.dart' as _i29;
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart'
    as _i661;
import 'package:mishwar/features/common/ride/data/datasources/ride_remote_data_source.dart'
    as _i747;
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart'
    as _i297;
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart'
    as _i422;
import 'package:mishwar/features/common/ride/domain/repositories/ride_repository.dart'
    as _i118;
import 'package:mishwar/features/common/ride/domain/usecases/accept_ride.dart'
    as _i851;
import 'package:mishwar/features/common/ride/domain/usecases/cancel_ride.dart'
    as _i72;
import 'package:mishwar/features/common/ride/domain/usecases/decline_ride.dart'
    as _i100;
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart'
    as _i811;
import 'package:mishwar/features/common/ride/domain/usecases/request_ride.dart'
    as _i892;
import 'package:mishwar/features/common/ride/domain/usecases/schedule_ride.dart'
    as _i731;
import 'package:mishwar/features/common/ride/domain/usecases/update_ride_status.dart'
    as _i759;
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart'
    as _i425;
import 'package:mishwar/features/common/ride/domain/usecases/watch_driver_location.dart'
    as _i787;
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart'
    as _i263;
import 'package:mishwar/features/common/ride/domain/usecases/watch_scheduled_rides.dart'
    as _i574;
import 'package:mishwar/features/common/ride/presentation/ride_receipt_cubit.dart'
    as _i60;
import 'package:mishwar/features/common/route/data/datasources/route_remote_data_source.dart'
    as _i400;
import 'package:mishwar/features/common/route/data/repositories/route_repository_impl.dart'
    as _i627;
import 'package:mishwar/features/common/route/domain/repositories/route_repository.dart'
    as _i1040;
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart'
    as _i598;
import 'package:mishwar/features/common/saved_places/data/saved_places_remote_data_source.dart'
    as _i693;
import 'package:mishwar/features/common/saved_places/data/saved_places_repository_impl.dart'
    as _i574;
import 'package:mishwar/features/common/saved_places/domain/saved_places_repository.dart'
    as _i552;
import 'package:mishwar/features/common/saved_places/domain/saved_places_usecases.dart'
    as _i1039;
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart'
    as _i806;
import 'package:mishwar/features/common/user/data/datasources/driver_remote_data_source.dart'
    as _i327;
import 'package:mishwar/features/common/user/data/datasources/user_remote_data_source.dart'
    as _i726;
import 'package:mishwar/features/common/user/data/repositories/driver_repository_impl.dart'
    as _i251;
import 'package:mishwar/features/common/user/data/repositories/user_repository_impl.dart'
    as _i18;
import 'package:mishwar/features/common/user/domain/repositories/driver_repository.dart'
    as _i95;
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart'
    as _i695;
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart'
    as _i801;
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart'
    as _i600;
import 'package:mishwar/features/common/user/domain/usecases/submit_driver_application.dart'
    as _i587;
import 'package:mishwar/features/common/user/domain/usecases/upload_license_photo.dart'
    as _i556;
import 'package:mishwar/features/common/user/domain/usecases/watch_driver.dart'
    as _i291;
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart'
    as _i106;
import 'package:mishwar/features/driver/earnings/data/earnings_remote_data_source.dart'
    as _i1008;
import 'package:mishwar/features/driver/earnings/data/earnings_repository_impl.dart'
    as _i429;
import 'package:mishwar/features/driver/earnings/domain/earnings_repository.dart'
    as _i63;
import 'package:mishwar/features/driver/earnings/domain/get_week_earnings.dart'
    as _i942;
import 'package:mishwar/features/driver/earnings/domain/watch_day_earnings.dart'
    as _i48;
import 'package:mishwar/features/driver/earnings/presentation/driver_earnings_cubit.dart'
    as _i371;
import 'package:mishwar/features/driver/earnings/presentation/earnings_screen_cubit.dart'
    as _i555;
import 'package:mishwar/features/driver/offer/presentation/bloc/driver_offer_bloc.dart'
    as _i804;
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart'
    as _i396;
import 'package:mishwar/features/driver/presence/data/driver_location_source.dart'
    as _i27;
import 'package:mishwar/features/driver/presence/data/driver_presence_repository_impl.dart'
    as _i319;
import 'package:mishwar/features/driver/presence/data/driver_tracking_repository_impl.dart'
    as _i879;
import 'package:mishwar/features/driver/presence/domain/driver_presence_repository.dart'
    as _i726;
import 'package:mishwar/features/driver/presence/domain/usecases/go_offline.dart'
    as _i247;
import 'package:mishwar/features/driver/presence/domain/usecases/go_online.dart'
    as _i89;
import 'package:mishwar/features/driver/presence/domain/usecases/publish_trip_location.dart'
    as _i36;
import 'package:mishwar/features/driver/presence/domain/usecases/update_driver_location.dart'
    as _i587;
import 'package:mishwar/features/driver/presence/domain/usecases/watch_driver_location.dart'
    as _i653;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart'
    as _i562;
import 'package:mishwar/features/driver/presence/presentation/bloc/presence_scheduler.dart'
    as _i262;
import 'package:mishwar/features/driver/trip/presentation/bloc/driver_trip_bloc.dart'
    as _i1059;
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart'
    as _i934;
import 'package:mishwar/features/rider/history/presentation/ride_history_cubit.dart'
    as _i831;
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart'
    as _i969;
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart'
    as _i786;
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart'
    as _i893;
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_clock.dart'
    as _i569;
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart'
    as _i448;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => firebaseModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.auth);
    gh.lazySingleton<_i892.FirebaseMessaging>(() => firebaseModule.messaging);
    gh.lazySingleton<_i43.PushRepository>(() => firebaseModule.pushRepository);
    gh.lazySingleton<_i457.FirebaseStorage>(() => firebaseModule.storage);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i809.FirebaseFunctions>(() => firebaseModule.functions);
    gh.lazySingleton<_i766.GeolocatorClient>(() => _i766.GeolocatorClient());
    gh.lazySingleton<_i304.FareCalculator>(() => const _i304.FareCalculator());
    gh.lazySingleton<_i804.OfferScheduler>(() => _i804.OfferScheduler());
    gh.lazySingleton<_i27.DriverLocationSource>(
      () => _i27.DriverLocationSource(),
    );
    gh.lazySingleton<_i262.PresenceScheduler>(() => _i262.PresenceScheduler());
    gh.lazySingleton<_i1059.TripTicker>(() => _i1059.TripTicker());
    gh.lazySingleton<_i569.RideTrackingClock>(() => _i569.RideTrackingClock());
    gh.lazySingleton<_i409.AdminRemoteDataSource>(
      () => _i409.AdminRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
        gh<_i809.FirebaseFunctions>(),
        gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i897.WatchPushRoutes>(
      () => _i897.WatchPushRoutes(gh<_i43.PushRepository>()),
    );
    gh.lazySingleton<_i897.GetInitialPushRoute>(
      () => _i897.GetInitialPushRoute(gh<_i43.PushRepository>()),
    );
    gh.lazySingleton<_i327.DriverRemoteDataSource>(
      () => _i327.DriverRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i159.LocaleCubit>(
      () => _i159.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i390.ThemeModeCubit>(
      () => _i390.ThemeModeCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i95.DriverRepository>(
      () => _i251.DriverRepositoryImpl(gh<_i327.DriverRemoteDataSource>()),
    );
    gh.lazySingleton<_i100.AccountRepository>(
      () => _i42.AccountRepositoryImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i587.SubmitDriverApplication>(
      () => _i587.SubmitDriverApplication(gh<_i95.DriverRepository>()),
    );
    gh.lazySingleton<_i556.UploadLicensePhoto>(
      () => _i556.UploadLicensePhoto(gh<_i95.DriverRepository>()),
    );
    gh.lazySingleton<_i291.WatchDriver>(
      () => _i291.WatchDriver(gh<_i95.DriverRepository>()),
    );
    gh.lazySingleton<_i243.AuthRemoteDataSource>(
      () => _i243.AuthRemoteDataSourceImpl(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i726.DriverPresenceRepository>(
      () => _i319.DriverPresenceRepositoryImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i1005.AdminRepository>(
      () => _i485.AdminRepositoryImpl(gh<_i409.AdminRemoteDataSource>()),
    );
    gh.lazySingleton<_i247.GoOffline>(
      () => _i247.GoOffline(gh<_i726.DriverPresenceRepository>()),
    );
    gh.lazySingleton<_i89.GoOnline>(
      () => _i89.GoOnline(gh<_i726.DriverPresenceRepository>()),
    );
    gh.lazySingleton<_i36.PublishTripLocation>(
      () => _i36.PublishTripLocation(gh<_i726.DriverPresenceRepository>()),
    );
    gh.lazySingleton<_i587.UpdateDriverLocation>(
      () => _i587.UpdateDriverLocation(gh<_i726.DriverPresenceRepository>()),
    );
    gh.lazySingleton<_i726.DriverTrackingRepository>(
      () => _i879.DriverTrackingRepositoryImpl(gh<_i27.DriverLocationSource>()),
    );
    gh.lazySingleton<_i653.WatchDriverLocation>(
      () => _i653.WatchDriverLocation(gh<_i726.DriverTrackingRepository>()),
    );
    gh.lazySingleton<_i101.LocationDataSource>(
      () => _i101.LocationDataSource(gh<_i766.GeolocatorClient>()),
    );
    gh.lazySingleton<_i29.PlacesRemoteDataSource>(
      () => _i29.PlacesRemoteDataSource(gh<_i809.FirebaseFunctions>()),
    );
    gh.lazySingleton<_i585.PromoRemoteDataSource>(
      () => _i585.PromoRemoteDataSource(gh<_i809.FirebaseFunctions>()),
    );
    gh.lazySingleton<_i400.RouteRemoteDataSource>(
      () => _i400.RouteRemoteDataSource(gh<_i809.FirebaseFunctions>()),
    );
    gh.lazySingleton<_i1040.RouteRepository>(
      () => _i627.RouteRepositoryImpl(gh<_i400.RouteRemoteDataSource>()),
    );
    gh.lazySingleton<_i1040.PlacesRepository>(
      () => _i692.PlacesRepositoryImpl(gh<_i29.PlacesRemoteDataSource>()),
    );
    gh.lazySingleton<_i693.SavedPlacesRemoteDataSource>(
      () => _i693.SavedPlacesRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i726.UserRemoteDataSource>(
      () => _i726.UserRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i1008.EarningsRemoteDataSource>(
      () => _i1008.EarningsRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i747.RideRemoteDataSource>(
      () => _i747.RideRemoteDataSource(
        gh<_i809.FirebaseFunctions>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i598.GetFareEstimates>(
      () => _i598.GetFareEstimates(gh<_i1040.RouteRepository>()),
    );
    gh.lazySingleton<_i285.PromoRepository>(
      () => _i587.PromoRepositoryImpl(gh<_i585.PromoRemoteDataSource>()),
    );
    gh.lazySingleton<_i180.AdminSignIn>(
      () => _i180.AdminSignIn(gh<_i1005.AdminRepository>()),
    );
    gh.lazySingleton<_i180.WatchAdminData>(
      () => _i180.WatchAdminData(gh<_i1005.AdminRepository>()),
    );
    gh.lazySingleton<_i180.LoadAdminPage>(
      () => _i180.LoadAdminPage(gh<_i1005.AdminRepository>()),
    );
    gh.lazySingleton<_i180.LoadAdminLicense>(
      () => _i180.LoadAdminLicense(gh<_i1005.AdminRepository>()),
    );
    gh.lazySingleton<_i180.AdminAction>(
      () => _i180.AdminAction(gh<_i1005.AdminRepository>()),
    );
    gh.lazySingleton<_i776.DeleteAccount>(
      () => _i776.DeleteAccount(gh<_i100.AccountRepository>()),
    );
    gh.lazySingleton<_i939.SwitchRole>(
      () => _i939.SwitchRole(gh<_i100.AccountRepository>()),
    );
    gh.lazySingleton<_i139.UpdateName>(
      () => _i139.UpdateName(gh<_i100.AccountRepository>()),
    );
    gh.lazySingleton<_i695.UserRepository>(
      () => _i18.UserRepositoryImpl(gh<_i726.UserRemoteDataSource>()),
    );
    gh.factory<_i396.DriverOnboardingCubit>(
      () => _i396.DriverOnboardingCubit(
        gh<_i556.UploadLicensePhoto>(),
        gh<_i587.SubmitDriverApplication>(),
      ),
    );
    gh.lazySingleton<_i164.ValidatePromo>(
      () => _i164.ValidatePromo(gh<_i285.PromoRepository>()),
    );
    gh.lazySingleton<_i63.EarningsRepository>(
      () => _i429.EarningsRepositoryImpl(gh<_i1008.EarningsRemoteDataSource>()),
    );
    gh.lazySingleton<_i300.LocationRepository>(
      () => _i578.LocationRepositoryImpl(gh<_i101.LocationDataSource>()),
    );
    gh.lazySingleton<_i552.SavedPlacesRepository>(
      () => _i574.SavedPlacesRepositoryImpl(
        gh<_i693.SavedPlacesRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i393.GetPlaceDetails>(
      () => _i393.GetPlaceDetails(gh<_i1040.PlacesRepository>()),
    );
    gh.lazySingleton<_i62.SearchPlaces>(
      () => _i62.SearchPlaces(gh<_i1040.PlacesRepository>()),
    );
    gh.lazySingleton<_i1039.WatchSavedPlaces>(
      () => _i1039.WatchSavedPlaces(gh<_i552.SavedPlacesRepository>()),
    );
    gh.lazySingleton<_i1039.UpsertSavedPlace>(
      () => _i1039.UpsertSavedPlace(gh<_i552.SavedPlacesRepository>()),
    );
    gh.lazySingleton<_i1039.AddOtherSavedPlace>(
      () => _i1039.AddOtherSavedPlace(gh<_i552.SavedPlacesRepository>()),
    );
    gh.lazySingleton<_i1039.RenameSavedPlace>(
      () => _i1039.RenameSavedPlace(gh<_i552.SavedPlacesRepository>()),
    );
    gh.lazySingleton<_i1039.DeleteSavedPlace>(
      () => _i1039.DeleteSavedPlace(gh<_i552.SavedPlacesRepository>()),
    );
    gh.factoryParam<
      _i448.DestinationSearchBloc,
      _i448.DestinationSearchParams,
      dynamic
    >(
      (params, _) => _i448.DestinationSearchBloc(
        gh<_i62.SearchPlaces>(),
        gh<_i393.GetPlaceDetails>(),
        params,
      ),
    );
    gh.lazySingleton<_i290.AuthRepository>(
      () => _i15.AuthRepositoryImpl(gh<_i243.AuthRemoteDataSource>()),
    );
    gh.factory<_i630.AdminCubit>(
      () => _i630.AdminCubit(
        gh<_i180.WatchAdminData>(),
        gh<_i180.LoadAdminPage>(),
        gh<_i180.AdminAction>(),
        gh<_i180.LoadAdminLicense>(),
        gh<_i304.FareCalculator>(),
      ),
    );
    gh.lazySingleton<_i118.RideRepository>(
      () => _i297.RideRepositoryImpl(gh<_i747.RideRemoteDataSource>()),
    );
    gh.factory<_i806.SavedPlacesCubit>(
      () => _i806.SavedPlacesCubit(
        gh<_i1039.WatchSavedPlaces>(),
        gh<_i1039.UpsertSavedPlace>(),
        gh<_i1039.AddOtherSavedPlace>(),
        gh<_i1039.RenameSavedPlace>(),
        gh<_i1039.DeleteSavedPlace>(),
      ),
    );
    gh.lazySingleton<_i801.CreateUserProfile>(
      () => _i801.CreateUserProfile(gh<_i695.UserRepository>()),
    );
    gh.lazySingleton<_i600.SetUserRole>(
      () => _i600.SetUserRole(gh<_i695.UserRepository>()),
    );
    gh.lazySingleton<_i106.WatchUser>(
      () => _i106.WatchUser(gh<_i695.UserRepository>()),
    );
    gh.lazySingleton<_i524.CheckLocationPermission>(
      () => _i524.CheckLocationPermission(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i107.CurrentPosition>(
      () => _i107.CurrentPosition(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i916.OpenAppSettings>(
      () => _i916.OpenAppSettings(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i682.OpenLocationSettings>(
      () => _i682.OpenLocationSettings(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i605.RequestLocationPermission>(
      () => _i605.RequestLocationPermission(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i365.WatchPosition>(
      () => _i365.WatchPosition(gh<_i300.LocationRepository>()),
    );
    gh.lazySingleton<_i563.SendOtp>(
      () => _i563.SendOtp(gh<_i290.AuthRepository>()),
    );
    gh.lazySingleton<_i454.VerifyOtp>(
      () => _i454.VerifyOtp(gh<_i290.AuthRepository>()),
    );
    gh.lazySingleton<_i584.WatchAuthState>(
      () => _i584.WatchAuthState(gh<_i290.AuthRepository>()),
    );
    gh.factory<_i520.RoleCubit>(() => _i520.RoleCubit(gh<_i600.SetUserRole>()));
    gh.lazySingleton<_i768.PushTokenSync>(
      () => _i768.PushTokenSync(
        gh<_i43.PushRepository>(),
        gh<_i290.AuthRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i899.RateRide>(
      () => _i899.RateRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i29.SkipRating>(
      () => _i29.SkipRating(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i851.AcceptRide>(
      () => _i851.AcceptRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i72.CancelRide>(
      () => _i72.CancelRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i100.DeclineRide>(
      () => _i100.DeclineRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i811.GetRideHistory>(
      () => _i811.GetRideHistory(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i892.RequestRide>(
      () => _i892.RequestRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i731.ScheduleRide>(
      () => _i731.ScheduleRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i759.UpdateRideStatus>(
      () => _i759.UpdateRideStatus(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i425.WatchActiveRideId>(
      () => _i425.WatchActiveRideId(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i787.WatchDriverLocation>(
      () => _i787.WatchDriverLocation(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i263.WatchRide>(
      () => _i263.WatchRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i574.WatchScheduledRides>(
      () => _i574.WatchScheduledRides(gh<_i118.RideRepository>()),
    );
    gh.factoryParam<_i267.OtpCubit, _i858.OtpSession, dynamic>(
      (session, _) =>
          _i267.OtpCubit(gh<_i454.VerifyOtp>(), gh<_i563.SendOtp>(), session),
    );
    gh.lazySingleton<_i942.GetWeekEarnings>(
      () => _i942.GetWeekEarnings(gh<_i63.EarningsRepository>()),
    );
    gh.lazySingleton<_i48.WatchDayEarnings>(
      () => _i48.WatchDayEarnings(gh<_i63.EarningsRepository>()),
    );
    gh.factoryParam<_i934.RideConfirmCubit, _i422.RideDraft, dynamic>(
      (draft, _) => _i934.RideConfirmCubit(
        gh<_i598.GetFareEstimates>(),
        gh<_i892.RequestRide>(),
        draft,
        scheduleRide: gh<_i731.ScheduleRide>(),
        validatePromo: gh<_i164.ValidatePromo>(),
      ),
    );
    gh.factory<_i786.RiderHomeCubit>(
      () => _i786.RiderHomeCubit(
        gh<_i524.CheckLocationPermission>(),
        gh<_i605.RequestLocationPermission>(),
        gh<_i107.CurrentPosition>(),
        gh<_i365.WatchPosition>(),
        gh<_i916.OpenAppSettings>(),
        gh<_i682.OpenLocationSettings>(),
      ),
    );
    gh.factoryParam<_i893.RideTrackingBloc, String, dynamic>(
      (rideId, _) => _i893.RideTrackingBloc(
        gh<_i263.WatchRide>(),
        gh<_i72.CancelRide>(),
        rideId,
        gh<_i787.WatchDriverLocation>(),
        gh<_i569.RideTrackingClock>(),
      ),
    );
    gh.factoryParam<_i1059.DriverTripBloc, String, dynamic>(
      (rideId, _) => _i1059.DriverTripBloc(
        rideId,
        gh<_i263.WatchRide>(),
        gh<_i759.UpdateRideStatus>(),
        gh<_i72.CancelRide>(),
        gh<_i1059.TripTicker>(),
      ),
    );
    gh.factory<_i60.RideReceiptCubit>(
      () => _i60.RideReceiptCubit(gh<_i263.WatchRide>()),
    );
    gh.lazySingleton<_i838.SessionCubit>(
      () => _i838.SessionCubit(
        gh<_i584.WatchAuthState>(),
        gh<_i106.WatchUser>(),
        gh<_i291.WatchDriver>(),
      ),
    );
    gh.factory<_i693.NameCubit>(
      () => _i693.NameCubit(gh<_i801.CreateUserProfile>()),
    );
    gh.factory<_i804.DriverOfferBloc>(
      () => _i804.DriverOfferBloc(
        gh<_i291.WatchDriver>(),
        gh<_i263.WatchRide>(),
        gh<_i851.AcceptRide>(),
        gh<_i100.DeclineRide>(),
        gh<_i804.OfferScheduler>(),
      ),
    );
    gh.factory<_i371.DriverEarningsCubit>(
      () => _i371.DriverEarningsCubit(gh<_i48.WatchDayEarnings>()),
    );
    gh.factory<_i964.PhoneCubit>(() => _i964.PhoneCubit(gh<_i563.SendOtp>()));
    gh.factory<_i555.EarningsScreenCubit>(
      () => _i555.EarningsScreenCubit(
        gh<_i942.GetWeekEarnings>(),
        gh<_i48.WatchDayEarnings>(),
        gh<_i811.GetRideHistory>(),
      ),
    );
    gh.lazySingleton<_i126.RegisterPushToken>(
      () => _i126.RegisterPushToken(
        gh<_i43.PushRepository>(),
        gh<_i768.PushTokenSync>(),
        gh<_i290.AuthRepository>(),
      ),
    );
    gh.factory<_i969.RecentPlacesCubit>(
      () => _i969.RecentPlacesCubit(gh<_i811.GetRideHistory>()),
    );
    gh.factoryParam<_i661.RatingCubit, String, _i176.RatingSide>(
      (rideId, side) => _i661.RatingCubit(
        gh<_i899.RateRide>(),
        gh<_i29.SkipRating>(),
        rideId,
        side,
      ),
    );
    gh.lazySingleton<_i282.UnregisterPushToken>(
      () => _i282.UnregisterPushToken(
        gh<_i43.PushRepository>(),
        gh<_i290.AuthRepository>(),
        gh<_i768.PushTokenSync>(),
      ),
    );
    gh.factory<_i831.RideHistoryCubit>(
      () => _i831.RideHistoryCubit(
        gh<_i811.GetRideHistory>(),
        watchScheduledRides: gh<_i574.WatchScheduledRides>(),
        cancelRide: gh<_i72.CancelRide>(),
      ),
    );
    gh.factory<_i562.DriverPresenceBloc>(
      () => _i562.DriverPresenceBloc(
        gh<_i291.WatchDriver>(),
        gh<_i524.CheckLocationPermission>(),
        gh<_i605.RequestLocationPermission>(),
        gh<_i107.CurrentPosition>(),
        gh<_i89.GoOnline>(),
        gh<_i247.GoOffline>(),
        gh<_i587.UpdateDriverLocation>(),
        gh<_i653.WatchDriverLocation>(),
        gh<_i916.OpenAppSettings>(),
        gh<_i262.PresenceScheduler>(),
        gh<_i126.RegisterPushToken>(),
        gh<_i36.PublishTripLocation>(),
      ),
    );
    gh.lazySingleton<_i442.SignOut>(
      () => _i442.SignOut(
        gh<_i290.AuthRepository>(),
        gh<_i282.UnregisterPushToken>(),
      ),
    );
    gh.factory<_i777.AccountCubit>(
      () => _i777.AccountCubit(
        gh<_i106.WatchUser>(),
        gh<_i291.WatchDriver>(),
        gh<_i139.UpdateName>(),
        gh<_i939.SwitchRole>(),
        gh<_i776.DeleteAccount>(),
        gh<_i442.SignOut>(),
      ),
    );
    gh.factory<_i104.HomeCubit>(() => _i104.HomeCubit(gh<_i442.SignOut>()));
    gh.factory<_i630.AdminLoginCubit>(
      () => _i630.AdminLoginCubit(gh<_i180.AdminSignIn>(), gh<_i442.SignOut>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i398.FirebaseModule {}
