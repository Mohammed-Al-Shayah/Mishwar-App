import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/promos/data/promo_quote_model.dart';
import 'package:mishwar/features/common/promos/data/promo_remote_data_source.dart';
import 'package:mishwar/features/common/promos/data/promo_repository_impl.dart';
import 'package:mishwar/features/common/promos/domain/promo_quote.dart';
import 'package:mishwar/features/common/promos/domain/validate_promo.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';
import '../../rider/confirm/ride_confirm_cubit_test.dart' show draft;

class MockPromoSource extends Mock implements PromoRemoteDataSource {}

void main() {
  test(
    'use case returns server quote and sends coordinates and selected vehicle',
    () async {
      final source = MockPromoSource();
      when(() => source.validate(any())).thenAnswer(
        (_) async => PromoQuoteModel.fromJson({
          'code': 'WELCOME50',
          'discount': 1.7,
          'fareBefore': 3.45,
          'fareAfter': 1.75,
        }),
      );
      final validate = ValidatePromo(PromoRepositoryImpl(source));
      expect(
        await validate('welcome50', draft, VehicleType.comfort),
        const Right<Failure, PromoQuote>(
          PromoQuote(
            code: 'WELCOME50',
            discountMinor: 1700,
            fareBeforeMinor: 3450,
            fareAfterMinor: 1750,
          ),
        ),
      );
      final sent =
          verify(() => source.validate(captureAny())).captured.single as Map;
      expect(sent['vehicleType'], 'comfort');
      expect(sent['code'], 'welcome50');
      expect(
        sent.keys,
        unorderedEquals(['code', 'vehicleType', 'pickup', 'dropoff']),
      );
    },
  );
  test(
    'all promo reasons map to typed failures including minimum fare',
    () async {
      final source = MockPromoSource();
      final validate = ValidatePromo(PromoRepositoryImpl(source));
      for (final reason in [
        'not-found',
        'inactive',
        'not-started',
        'expired',
        'limit-reached',
        'user-limit',
        'first-ride-only',
        'min-fare',
        'rate-limit',
      ]) {
        when(() => source.validate(any())).thenThrow(
          FirebaseFunctionsException(
            message: 'Rejected',
            code: 'failed-precondition',
            details: {'reason': reason, 'minFare': 3},
          ),
        );
        expect(
          await validate('CODE', draft, VehicleType.economy),
          Left<Failure, PromoQuote>(PromoFailure(reason, minFareMinor: 3000)),
        );
      }
      when(
        () => source.validate(any()),
      ).thenThrow(
        FirebaseFunctionsException(message: 'Unavailable', code: 'unavailable'),
      );
      expect(
        (await validate(
          'CODE',
          draft,
          VehicleType.economy,
        )).getLeft().toNullable(),
        isA<NetworkFailure>(),
      );
    },
  );
}
