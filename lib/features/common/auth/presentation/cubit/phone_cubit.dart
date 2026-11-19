import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/get_otp_protection.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';

class PhoneState extends Equatable {
  const PhoneState({
    this.phone = '',
    this.country = PhoneCountry.jordan,
    this.isLoading = false,
    this.failure,
    this.session,
    this.remaining = 0,
    this.locked = false,
  });
  final String phone;
  final PhoneCountry country;
  final bool isLoading;
  final Failure? failure;
  final OtpSession? session;
  final int remaining;
  final bool locked;
  String? get normalizedPhone => normalizePhone(phone, country: country);
  PhoneState copyWith({
    String? phone,
    PhoneCountry? country,
    bool? isLoading,
    Failure? failure,
    OtpSession? session,
    int? remaining,
    bool? locked,
  }) => PhoneState(
    phone: phone ?? this.phone,
    country: country ?? this.country,
    isLoading: isLoading ?? this.isLoading,
    failure: failure,
    session: session,
    remaining: remaining ?? this.remaining,
    locked: locked ?? this.locked,
  );
  @override
  List<Object?> get props => [
    phone,
    country,
    isLoading,
    failure,
    session,
    remaining,
    locked,
  ];
}

@injectable
class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._sendOtp, this._protection)
    : super(
        PhoneState(
          country: PhoneCountry.fromRegion(
            WidgetsBinding.instance.platformDispatcher.locale.countryCode,
          ),
        ),
      ) {
    unawaited(_refresh());
  }
  final SendOtp _sendOtp;
  final GetOtpProtection _protection;
  Timer? _timer;
  Future<void> _refresh() async {
    final phone = state.normalizedPhone ?? '';
    final result = await _protection(phone);
    if (isClosed || phone != (state.normalizedPhone ?? '')) return;
    result.fold((failure) => emit(state.copyWith(failure: failure)), (value) {
      if (state.remaining != value.remaining || state.locked != value.locked) {
        emit(
          state.copyWith(
            remaining: value.remaining,
            locked: value.locked,
            failure: state.failure,
            session: state.session,
          ),
        );
      }
      if (value.remaining > 0) {
        _timer ??= Timer.periodic(
          const Duration(seconds: 1),
          (_) => unawaited(_refresh()),
        );
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void phoneChanged(String phone) {
    if (!state.isLoading) {
      emit(state.copyWith(phone: phone, remaining: 0, locked: false));
      unawaited(_refresh());
    }
  }

  void countryChanged(PhoneCountry country) {
    if (!state.isLoading) {
      emit(state.copyWith(country: country, remaining: 0, locked: false));
      unawaited(_refresh());
    }
  }

  Future<void> submit() async {
    final phone = state.normalizedPhone;
    if (phone == null || state.isLoading || state.remaining > 0) return;
    emit(state.copyWith(isLoading: true));
    final result = await _sendOtp(SendOtpParams(phone));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (session) => emit(state.copyWith(isLoading: false, session: session)),
    );
    await _refresh();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
