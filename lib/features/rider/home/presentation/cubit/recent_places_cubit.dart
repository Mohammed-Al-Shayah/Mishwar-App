import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_history.dart';
import 'package:mishwar/features/common/ride/domain/usecases/get_ride_history.dart';

/// The last two distinct destinations of completed rides (rider home row 5).
@injectable
class RecentPlacesCubit extends Cubit<List<PlaceDetails>> {
  RecentPlacesCubit(this._history) : super(const []);
  final GetRideHistory _history;
  static const count = 2;
  int _generation = 0;

  Future<void> load(String uid) async {
    final generation = ++_generation;
    final seen = <String>{};
    final places = <PlaceDetails>[];
    HistoryCursor? after;
    // Bounded: at most three history pages (30 rides) for two shortcuts.
    var pages = 0;
    do {
      pages++;
      final result = await _history(
        party: RideParty.rider,
        uid: uid,
        after: after,
        limit: 10,
      );
      if (isClosed || generation != _generation) return;
      // Recent places are a convenience: a failure simply shows none.
      if (result.isLeft()) {
        emit(const []);
        return;
      }
      final page = result.getOrElse((_) => RideHistoryPage(items: []));
      for (final ride in page.items) {
        if (ride.status != RideStatus.completed) continue;
        final stop = ride.dropoff;
        if (!seen.add(stop.name.trim().toLowerCase())) continue;
        places.add(
          PlaceDetails(
            placeId: 'recent-${ride.id}',
            name: stop.name,
            address: stop.address,
            location: stop.location,
          ),
        );
        if (places.length == count) break;
      }
      after = page.next;
    } while (places.length < count && after != null && pages < 3);
    emit(List.unmodifiable(places));
  }
}
