import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';

enum RideParty { rider, driver }

/// Opaque continuation token; its Firestore representation stays in data.
abstract class HistoryCursor {
  const HistoryCursor();
}

typedef DocumentCursor = HistoryCursor;

class RideHistoryPage {
  RideHistoryPage({required List<RideEntity> items, this.next})
    : items = List.unmodifiable(items);
  final List<RideEntity> items;
  final HistoryCursor? next;
  bool get hasMore => next != null;
}
