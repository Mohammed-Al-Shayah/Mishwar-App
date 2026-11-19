import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/ride/data/models/ride_model.dart';
import 'package:mishwar/features/common/ride/data/repositories/ride_repository_impl.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/cancellation_quote.dart';
import 'package:mishwar/features/common/ride/presentation/fee_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_screen.dart';
import 'package:mishwar/features/common/user/data/models/user_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../history/history_widgets_test.dart' show historySize, historyWrap;
import 'ride_data_test.dart' show MockSource, rideJson;

void main() {
  test('fee models default legacy values and map server minor', () {
    final legacy = RideModel.fromJson(rideJson()).toEntity();
    expect(legacy.fareCancellationFeeMinor, 0);
    expect(legacy.fareWaitingFeeMinor, 0);
    expect(legacy.farePreviousBalanceMinor, 0);
    final model = RideModel.fromJson(rideJson()).copyWith(
      fare: const RideFareModel(
        estimated: 2.5,
        currency: 'JOD',
        cancellationFee: 0.5,
        waitingFee: 0.1,
        previousBalance: 1,
      ),
    );
    expect(model.toEntity().fareCancellationFeeMinor, 500);
    expect(model.toEntity().fareWaitingFeeMinor, 100);
    expect(model.toEntity().farePreviousBalanceMinor, 1000);
    expect(
      () =>
          model.copyWith(fare: model.fare.copyWith(waitingFee: -1)).toEntity(),
      throwsFormatException,
    );
    final user = UserModel.fromJson({
      'id': 'r',
      'name': 'Rider',
      'phone': '+96278',
      'createdAt': Timestamp.fromDate(DateTime.utc(2026)),
      'balanceDueFils': 500,
    });
    expect(user.toEntity().balanceDueMinor, 500);
    expect(user.toEntity().copyWith(name: 'New').balanceDueMinor, 500);
    expect(
      UserModel.fromEntity(user.toEntity()).toJson(),
      isNot(contains('balanceDueMinor')),
    );
  });
  test('quote use case maps source and failure through repository', () async {
    final source = MockSource();
    final quote = CancellationQuote(RideRepositoryImpl(source));
    when(() => source.cancellationQuote('x')).thenAnswer((_) async => 500);
    expect(await quote('x'), const Right<Failure, int>(500));
    when(
      () => source.cancellationQuote('x'),
    ).thenThrow(
      FirebaseFunctionsException(code: 'unavailable', message: 'Offline'),
    );
    expect((await quote('x')).isLeft(), isTrue);
  });
  for (final language in ['ar', 'en']) {
    testWidgets('$language cancelled receipt total is the cancellation fee', (
      tester,
    ) async {
      historySize(tester);
      final model = RideModel.fromJson(rideJson()).copyWith(
        status: RideStatus.cancelled,
        fare: const RideFareModel(
          estimated: 2.5,
          currency: 'JOD',
          cancellationFee: 0.5,
        ),
      );
      await tester.pumpWidget(
        historyWrap(
          Scaffold(body: RideReceiptContent(ride: model.toEntity())),
          language: language,
        ),
      );
      expect(find.textContaining('0.50'), findsNWidgets(2));
      expect(find.textContaining('2.50'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      '$language waiting countdown and charge rate at text scale 1.3',
      (tester) async {
        historySize(tester);
        final start = DateTime.utc(2026);
        await tester.pumpWidget(
          historyWrap(
            Scaffold(
              body: WaitingFeeNotice(
                arrivedAt: start,
                now: start.add(const Duration(seconds: 19)),
              ),
            ),
            language: language,
          ),
        );
        expect(find.textContaining('2:41'), findsOneWidget);
        await tester.pumpWidget(
          historyWrap(
            Scaffold(
              body: WaitingFeeNotice(
                arrivedAt: start,
                now: start.add(const Duration(seconds: 180)),
              ),
            ),
            language: language,
          ),
        );
        expect(find.textContaining('0.05'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    for (final driver in [false, true]) {
      testWidgets(
        '$language driver=$driver receipt fees and total at scale 1.3',
        (tester) async {
          historySize(tester);
          final model = RideModel.fromJson(rideJson()).copyWith(
            status: RideStatus.completed,
            fare: const RideFareModel(
              estimated: 2.5,
              currency: 'JOD',
              finalAmount: 3.1,
              waitingFee: 0.1,
              previousBalance: 0.5,
            ),
          );
          await tester.pumpWidget(
            historyWrap(
              Scaffold(
                body: RideReceiptContent(
                  ride: model.toEntity(),
                  driver: driver,
                ),
              ),
              language: language,
              dark: driver,
            ),
          );
          expect(find.textContaining('0.10'), findsOneWidget);
          expect(find.textContaining('0.50'), findsOneWidget);
          expect(find.textContaining('3.10'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
