import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/saved_places/domain/saved_place.dart';
import 'package:mishwar/features/common/saved_places/presentation/saved_places_cubit.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/home/presentation/cubit/recent_places_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAppConfigCubit extends MockCubit<AppConfigState>
    implements AppConfigCubit {}

MockAppConfigCubit appConfigCubit() {
  final cubit = MockAppConfigCubit();
  whenListen(
    cubit,
    const Stream<AppConfigState>.empty(),
    initialState: AppConfigState(),
  );
  when(() => cubit.start(any())).thenAnswer((_) async {});
  when(cubit.stop).thenAnswer((_) async {});
  return cubit;
}

class MockSavedPlacesCubit extends MockCubit<SavedPlacesState>
    implements SavedPlacesCubit {}

class MockRecentPlacesCubit extends MockCubit<List<PlaceDetails>>
    implements RecentPlacesCubit {}

const savedHome = SavedPlace(
  id: 'home',
  label: SavedPlaceLabel.home,
  name: 'My house',
  address: 'Home street',
  location: GeoPointValue(31, 35),
);
const savedOther = SavedPlace(
  id: 'park',
  label: SavedPlaceLabel.other,
  name: 'Park',
  address: 'Garden street',
  location: GeoPointValue(32, 35),
);

MockSavedPlacesCubit savedCubit({List<SavedPlace> places = const []}) {
  final cubit = MockSavedPlacesCubit();
  whenListen(
    cubit,
    const Stream<SavedPlacesState>.empty(),
    initialState: SavedPlacesState(places: places, loading: false),
  );
  when(() => cubit.start(any())).thenAnswer((_) async {});
  return cubit;
}

MockRecentPlacesCubit recentCubit({List<PlaceDetails> places = const []}) {
  final cubit = MockRecentPlacesCubit();
  whenListen(
    cubit,
    const Stream<List<PlaceDetails>>.empty(),
    initialState: places,
  );
  when(() => cubit.load(any())).thenAnswer((_) async {});
  return cubit;
}

Widget savedProviders(Widget child) => MultiBlocProvider(
  providers: [
    BlocProvider<AppConfigCubit>(create: (_) => appConfigCubit()),
    BlocProvider<SavedPlacesCubit>(create: (_) => savedCubit()),
    BlocProvider<RecentPlacesCubit>(create: (_) => recentCubit()),
  ],
  child: child,
);

void registerSavedPlaces() {
  getIt
    ..registerFactory<AppConfigCubit>(appConfigCubit)
    ..registerFactory<SavedPlacesCubit>(savedCubit)
    ..registerFactory<RecentPlacesCubit>(recentCubit);
}
