import 'dart:async';

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/get_otp_protection.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';

class OtpState extends Equatable {
  const OtpState({
    required this.session,
    this.code = '',
    this.remaining = 60,
    this.wrongAttempts = 0,
    this.locked = false,
    this.isLoading = false,
    this.failure,
    this.succeeded = false,
  });
  final OtpSession session;
  final String code;
  final int remaining;
  final int wrongAttempts;
  final bool locked;
  bool get needsNewCode => wrongAttempts >= 5;
  final bool isLoading;
  final Failure? failure;
  final bool succeeded;
  OtpState copyWith({
    OtpSession? session,
    String? code,
    int? remaining,
    int? wrongAttempts,
    bool? locked,
    bool? isLoading,
    Failure? failure,
    bool? succeeded,
  }) => OtpState(
    session: session ?? this.session,
    code: code ?? this.code,
    remaining: remaining ?? this.remaining,
    wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    locked: locked ?? this.locked,
    isLoading: isLoading ?? this.isLoading,
    failure: failure,
    succeeded: succeeded ?? this.succeeded,
  );
  @override
  List<Object?> get props => [
    session,
    code,
    remaining,
    wrongAttempts,
    locked,
    isLoading,
    failure,
    succeeded,
  ];
}

@injectable
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(
    this._verifyOtp,
    this._sendOtp,
    this._protection,
    @factoryParam OtpSession session,
  ) : super(OtpState(session: session)) {
    _startTimer();
    unawaited(_refreshProtection());
  }
  final VerifyOtp _verifyOtp;
  final SendOtp _sendOtp;
  final GetOtpProtection _protection;
  Future<void> _refreshProtection() async {
    final result = await _protection(state.session.phone);
    if (isClosed) return;
    result.fold((failure) => emit(state.copyWith(failure: failure)), (value) {
      emit(
        state.copyWith(
          remaining: value.remaining,
          locked: value.locked,
          failure: state.failure,
        ),
      );
      _startTimer();
    });
  }

  Timer? _timer;
  void _startTimer() {
    _timer?.cancel();
    if (state.remaining <= 0) return;
    final until = clock.now().add(Duration(seconds: state.remaining));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = ((until.difference(clock.now()).inMilliseconds) / 1000)
          .ceil()
          .clamp(0, 900);
      emit(
        state.copyWith(
          remaining: remaining,
          locked: state.locked && remaining > 0,
          failure: state.failure,
        ),
      );
      if (remaining == 0) timer.cancel();
    });
  }

  void codeChanged(String code) {
    if (state.isLoading || state.succeeded || state.needsNewCode) return;
    emit(state.copyWith(code: code));
    if (RegExp(r'^[0-9]{6}$').hasMatch(code) && code.length == 6) {
      unawaited(submit());
    }
  }

  Future<void> submit() async {
    if (state.isLoading ||
        state.succeeded ||
        state.needsNewCode ||
        state.code.length != 6) {
      return;
    }
    emit(state.copyWith(isLoading: true));
    final result = await _verifyOtp(
      VerifyOtpParams(session: state.session, code: state.code),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          failure: failure,
          wrongAttempts:
              failure is AuthFailure &&
                  failure.code == AuthFailureCode.codeExpired
              ? 5
              : state.wrongAttempts +
                    (failure is AuthFailure &&
                            failure.code == AuthFailureCode.invalidCode
                        ? 1
                        : 0),
        ),
      ),
      (_) => emit(state.copyWith(isLoading: false, succeeded: true)),
    );
  }

  Future<void> resend() async {
    if (state.remaining > 0 || state.isLoading || state.succeeded) return;
    emit(state.copyWith(isLoading: true));
    final result = await _sendOtp(
      SendOtpParams(state.session.phone, resendFrom: state.session),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (session) {
        emit(OtpState(session: session));
        _startTimer();
      },
    );
    await _refreshProtection();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
