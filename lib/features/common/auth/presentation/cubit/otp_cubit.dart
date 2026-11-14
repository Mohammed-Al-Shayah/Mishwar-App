import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';
import 'package:mishwar/features/common/auth/domain/usecases/verify_otp.dart';

class OtpState extends Equatable {
  const OtpState({
    required this.session,
    this.code = '',
    this.remaining = 30,
    this.isLoading = false,
    this.failure,
    this.succeeded = false,
  });
  final OtpSession session;
  final String code;
  final int remaining;
  final bool isLoading;
  final Failure? failure;
  final bool succeeded;
  OtpState copyWith({
    OtpSession? session,
    String? code,
    int? remaining,
    bool? isLoading,
    Failure? failure,
    bool? succeeded,
  }) => OtpState(
    session: session ?? this.session,
    code: code ?? this.code,
    remaining: remaining ?? this.remaining,
    isLoading: isLoading ?? this.isLoading,
    failure: failure,
    succeeded: succeeded ?? this.succeeded,
  );
  @override
  List<Object?> get props => [
    session,
    code,
    remaining,
    isLoading,
    failure,
    succeeded,
  ];
}

@injectable
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._verifyOtp, this._sendOtp, @factoryParam OtpSession session)
    : super(OtpState(session: session)) {
    _startTimer();
  }
  final VerifyOtp _verifyOtp;
  final SendOtp _sendOtp;
  Timer? _timer;
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remaining - 1;
      emit(state.copyWith(remaining: remaining, failure: state.failure));
      if (remaining == 0) timer.cancel();
    });
  }

  void codeChanged(String code) {
    if (state.isLoading || state.succeeded) return;
    emit(state.copyWith(code: code));
    if (RegExp(r'^[0-9]{6}$').hasMatch(code) && code.length == 6) {
      unawaited(submit());
    }
  }

  Future<void> submit() async {
    if (state.isLoading || state.succeeded || state.code.length != 6) return;
    emit(state.copyWith(isLoading: true));
    final result = await _verifyOtp(
      VerifyOtpParams(session: state.session, code: state.code),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
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
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
