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
import 'package:mishwar/features/common/user/data/datasources/user_remote_data_source.dart'
    as _i726;
import 'package:mishwar/features/common/user/data/repositories/user_repository_impl.dart'
    as _i18;
import 'package:mishwar/features/common/user/domain/repositories/user_repository.dart'
    as _i695;
import 'package:mishwar/features/common/user/domain/usecases/create_user_profile.dart'
    as _i801;
import 'package:mishwar/features/common/user/domain/usecases/set_user_role.dart'
    as _i600;
import 'package:mishwar/features/common/user/domain/usecases/watch_user.dart'
    as _i106;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.auth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i809.FirebaseFunctions>(() => firebaseModule.functions);
    gh.lazySingleton<_i243.AuthRemoteDataSource>(
      () => _i243.AuthRemoteDataSourceImpl(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i726.UserRemoteDataSource>(
      () => _i726.UserRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i695.UserRepository>(
      () => _i18.UserRepositoryImpl(gh<_i726.UserRemoteDataSource>()),
    );
    gh.lazySingleton<_i290.AuthRepository>(
      () => _i15.AuthRepositoryImpl(gh<_i243.AuthRemoteDataSource>()),
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
    gh.factoryParam<_i267.OtpCubit, _i858.OtpSession, dynamic>(
      (session, _) =>
          _i267.OtpCubit(gh<_i454.VerifyOtp>(), gh<_i563.SendOtp>(), session),
    );
    gh.factory<_i104.HomeCubit>(() => _i104.HomeCubit(gh<_i442.SignOut>()));
    gh.factory<_i693.NameCubit>(
      () => _i693.NameCubit(gh<_i801.CreateUserProfile>()),
    );
    gh.factory<_i964.PhoneCubit>(() => _i964.PhoneCubit(gh<_i563.SendOtp>()));
    gh.lazySingleton<_i838.SessionCubit>(
      () =>
          _i838.SessionCubit(gh<_i584.WatchAuthState>(), gh<_i106.WatchUser>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i398.FirebaseModule {}
