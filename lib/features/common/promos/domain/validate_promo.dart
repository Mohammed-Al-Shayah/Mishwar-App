import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/promos/domain/promo_repository.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_draft.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

@lazySingleton
class ValidatePromo {
  const ValidatePromo(this._repository);
  final PromoRepository _repository;
  Future<Either<Failure, PromoQuote>> call(
    String code,
    RideDraft draft,
    VehicleType vehicleType,
  ) => _repository.validate(code, draft, vehicleType);
}
