import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

// Repository abstraction keeps callable details out of the domain.
// ignore: one_member_abstracts
abstract class PromoRepository {
  Future<Either<Failure, PromoQuote>> validate(
    String code,
    RideDraft draft,
    VehicleType vehicleType,
  );
}
