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
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mishwar/core/di/register_module.dart' as _i398;
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
import 'package:mishwar/features/common/ride/domain/usecases/request_ride.dart'
    as _i892;
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart'
    as _i425;
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart'
    as _i263;
import 'package:mishwar/features/common/route/data/datasources/route_remote_data_source.dart'
    as _i400;
import 'package:mishwar/features/common/route/data/repositories/route_repository_impl.dart'
    as _i627;
import 'package:mishwar/features/common/route/domain/repositories/route_repository.dart'
    as _i1040;
import 'package:mishwar/features/common/route/domain/usecases/get_fare_estimates.dart'
    as _i598;
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
import 'package:mishwar/features/driver/presence/domain/usecases/update_driver_location.dart'
    as _i587;
import 'package:mishwar/features/driver/presence/domain/usecases/watch_driver_location.dart'
    as _i653;
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart'
    as _i562;
import 'package:mishwar/features/driver/presence/presentation/bloc/presence_scheduler.dart'
    as _i262;
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart'
    as _i934;
import 'package:mishwar/features/rider/home/presentation/cubit/rider_home_cubit.dart'
    as _i786;
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart'
    as _i893;
import 'package:mishwar/features/rider/search/presentation/bloc/destination_search_bloc.dart'
    as _i448;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.auth);
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
    gh.lazySingleton<_i327.DriverRemoteDataSource>(
      () => _i327.DriverRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
        gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i95.DriverRepository>(
      () => _i251.DriverRepositoryImpl(gh<_i327.DriverRemoteDataSource>()),
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
    gh.lazySingleton<_i247.GoOffline>(
      () => _i247.GoOffline(gh<_i726.DriverPresenceRepository>()),
    );
    gh.lazySingleton<_i89.GoOnline>(
      () => _i89.GoOnline(gh<_i726.DriverPresenceRepository>()),
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
    gh.lazySingleton<_i400.RouteRemoteDataSource>(
      () => _i400.RouteRemoteDataSource(gh<_i809.FirebaseFunctions>()),
    );
    gh.lazySingleton<_i1040.RouteRepository>(
      () => _i627.RouteRepositoryImpl(gh<_i400.RouteRemoteDataSource>()),
    );
    gh.lazySingleton<_i1040.PlacesRepository>(
      () => _i692.PlacesRepositoryImpl(gh<_i29.PlacesRemoteDataSource>()),
    );
    gh.lazySingleton<_i726.UserRemoteDataSource>(
      () => _i726.UserRemoteDataSource(gh<_i974.FirebaseFirestore>()),
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
    gh.lazySingleton<_i695.UserRepository>(
      () => _i18.UserRepositoryImpl(gh<_i726.UserRemoteDataSource>()),
    );
    gh.factory<_i396.DriverOnboardingCubit>(
      () => _i396.DriverOnboardingCubit(
        gh<_i556.UploadLicensePhoto>(),
        gh<_i587.SubmitDriverApplication>(),
      ),
    );
    gh.lazySingleton<_i300.LocationRepository>(
      () => _i578.LocationRepositoryImpl(gh<_i101.LocationDataSource>()),
    );
    gh.lazySingleton<_i393.GetPlaceDetails>(
      () => _i393.GetPlaceDetails(gh<_i1040.PlacesRepository>()),
    );
    gh.lazySingleton<_i62.SearchPlaces>(
      () => _i62.SearchPlaces(gh<_i1040.PlacesRepository>()),
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
    gh.lazySingleton<_i118.RideRepository>(
      () => _i297.RideRepositoryImpl(gh<_i747.RideRemoteDataSource>()),
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
    gh.lazySingleton<_i442.SignOut>(
      () => _i442.SignOut(gh<_i290.AuthRepository>()),
    );
    gh.lazySingleton<_i454.VerifyOtp>(
      () => _i454.VerifyOtp(gh<_i290.AuthRepository>()),
    );
    gh.lazySingleton<_i584.WatchAuthState>(
      () => _i584.WatchAuthState(gh<_i290.AuthRepository>()),
    );
    gh.factory<_i520.RoleCubit>(() => _i520.RoleCubit(gh<_i600.SetUserRole>()));
    gh.lazySingleton<_i851.AcceptRide>(
      () => _i851.AcceptRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i72.CancelRide>(
      () => _i72.CancelRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i100.DeclineRide>(
      () => _i100.DeclineRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i892.RequestRide>(
      () => _i892.RequestRide(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i425.WatchActiveRideId>(
      () => _i425.WatchActiveRideId(gh<_i118.RideRepository>()),
    );
    gh.lazySingleton<_i263.WatchRide>(
      () => _i263.WatchRide(gh<_i118.RideRepository>()),
    );
    gh.factoryParam<_i267.OtpCubit, _i858.OtpSession, dynamic>(
      (session, _) =>
          _i267.OtpCubit(gh<_i454.VerifyOtp>(), gh<_i563.SendOtp>(), session),
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
    gh.factory<_i104.HomeCubit>(() => _i104.HomeCubit(gh<_i442.SignOut>()));
    gh.factoryParam<_i934.RideConfirmCubit, _i422.RideDraft, dynamic>(
      (draft, _) => _i934.RideConfirmCubit(
        gh<_i598.GetFareEstimates>(),
        gh<_i892.RequestRide>(),
        draft,
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
      ),
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
    gh.factory<_i964.PhoneCubit>(() => _i964.PhoneCubit(gh<_i563.SendOtp>()));
    gh.factoryParam<_i893.RideTrackingBloc, String, dynamic>(
      (rideId, _) => _i893.RideTrackingBloc(
        gh<_i263.WatchRide>(),
        gh<_i72.CancelRide>(),
        rideId,
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i398.FirebaseModule {}
