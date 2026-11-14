import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/otp_session.dart';
import 'package:mishwar/features/common/auth/domain/usecases/send_otp.dart';

class PhoneState extends Equatable {
  const PhoneState({
    this.phone = '',
    this.isLoading = false,
    this.failure,
    this.session,
  });
  final String phone;
  final bool isLoading;
  final Failure? failure;
  final OtpSession? session;
  String? get normalizedPhone {
    if (!RegExp(r'^0?7[0-9]{8}$').hasMatch(phone) || phone.endsWith('\n')) {
      return null;
    }
    return '+962${phone.startsWith('0') ? phone.substring(1) : phone}';
  }

  @override
  List<Object?> get props => [phone, isLoading, failure, session];
}

@injectable
class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._sendOtp) : super(const PhoneState());
  final SendOtp _sendOtp;
  void phoneChanged(String phone) {
    if (!state.isLoading) emit(PhoneState(phone: phone));
  }

  Future<void> submit() async {
    final phone = state.normalizedPhone;
    if (phone == null || state.isLoading) return;
    final input = state.phone;
    emit(PhoneState(phone: input, isLoading: true));
    final result = await _sendOtp(SendOtpParams(phone));
    if (isClosed) return;
    result.fold(
      (failure) => emit(PhoneState(phone: input, failure: failure)),
      (session) => emit(PhoneState(phone: input, session: session)),
    );
  }
}
