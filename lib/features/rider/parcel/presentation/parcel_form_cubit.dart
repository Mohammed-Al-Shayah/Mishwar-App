import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/validation/jordan_phone.dart';
import 'package:mishwar/features/common/location/domain/usecases/current_position.dart';
import 'package:mishwar/features/common/ride/domain/entities/parcel_details.dart';
import 'package:mishwar/features/common/ride/domain/usecases/parcel_usecases.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class ParcelFormState extends Equatable {
  const ParcelFormState({
    this.busy = false,
    this.progress,
    this.photoPath,
    this.failure,
    this.invalid = false,
  });
  final bool busy;
  final double? progress;
  final String? photoPath;
  final Failure? failure;
  final bool invalid;
  @override
  List<Object?> get props => [busy, progress, photoPath, failure, invalid];
}

@injectable
class ParcelFormCubit extends Cubit<ParcelFormState> {
  ParcelFormCubit(this._upload, this._position)
    : super(const ParcelFormState());
  final UploadParcelPhoto _upload;
  final CurrentPosition _position;

  void photoFailed() => emit(
    ParcelFormState(
      photoPath: state.photoPath,
      failure: const ServerFailure('photo'),
    ),
  );
  Future<void> upload(String uid, Uint8List bytes) async {
    if (state.busy) return;
    emit(const ParcelFormState(busy: true, progress: 0));
    await for (final result in _upload(uid, bytes)) {
      if (isClosed) return;
      result.fold(
        (f) => emit(ParcelFormState(failure: f)),
        (p) => emit(
          ParcelFormState(
            busy: p.path == null,
            progress: p.progress,
            photoPath: p.path,
          ),
        ),
      );
    }
  }

  ParcelDetails? validate(String name, String phone, String description) {
    final normalized = normalizeJordanPhone(phone);
    if (name.trim().isEmpty ||
        name.trim().length > 40 ||
        normalized == null ||
        description.trim().isEmpty ||
        description.trim().length > 200) {
      emit(ParcelFormState(photoPath: state.photoPath, invalid: true));
      return null;
    }
    return ParcelDetails(
      recipientName: name.trim(),
      recipientPhone: normalized,
      description: description.trim(),
      photoPath: state.photoPath,
    );
  }

  Future<GeoPointValue?> pickup() async {
    if (state.busy) return null;
    emit(ParcelFormState(busy: true, photoPath: state.photoPath));
    final result = await _position();
    if (isClosed) return null;
    emit(
      ParcelFormState(
        photoPath: state.photoPath,
        failure: result.getLeft().toNullable(),
      ),
    );
    return result.getRight().toNullable();
  }
}
