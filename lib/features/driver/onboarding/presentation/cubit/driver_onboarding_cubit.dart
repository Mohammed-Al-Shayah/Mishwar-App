import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/common/user/domain/usecases/submit_driver_application.dart';
import 'package:mishwar/features/common/user/domain/usecases/upload_license_photo.dart';

class DriverOnboardingState extends Equatable {
  const DriverOnboardingState({
    this.type = VehicleType.economy,
    this.errors = const {},
    this.isLoading = false,
    this.succeeded = false,
    this.failure,
    this.photo,
    this.photoPath,
    this.attempted = false,
  });
  final VehicleType type;
  final Map<String, ValidationFailure> errors;
  final bool isLoading;
  final bool succeeded;
  final bool attempted;
  final Failure? failure;
  final Uint8List? photo;
  final String? photoPath;
  @override
  List<Object?> get props => [
    type,
    errors,
    isLoading,
    succeeded,
    failure,
    photo,
    photoPath,
    attempted,
  ];
}

@injectable
class DriverOnboardingCubit extends Cubit<DriverOnboardingState> {
  DriverOnboardingCubit(this._upload, this._submit)
    : super(const DriverOnboardingState());
  final UploadLicensePhoto _upload;
  final SubmitDriverApplication _submit;
  String _make = '';
  String _model = '';
  String _color = '';
  String _plate = '';
  String _contentType = 'image/jpeg';
  VehicleEntity get vehicle => VehicleEntity(
    type: state.type,
    make: _make,
    model: _model,
    color: _color,
    plate: _plate,
  );
  void prefill(DriverEntity? driver) {
    if (driver == null) return;
    _make = driver.vehicle.make;
    _model = driver.vehicle.model;
    _color = driver.vehicle.color;
    _plate = driver.vehicle.plate;
    emit(
      DriverOnboardingState(
        type: driver.vehicle.type,
        photoPath: driver.licensePhotoPath,
      ),
    );
  }

  void _change({VehicleType? type, Uint8List? photo, Failure? failure}) {
    if (state.isLoading || state.succeeded) return;
    final nextPhoto = photo ?? state.photo;
    emit(
      DriverOnboardingState(
        type: type ?? state.type,
        photo: nextPhoto,
        photoPath: state.photoPath,
        attempted: state.attempted,
        errors: state.attempted
            ? applicationErrors(
                VehicleEntity(
                  type: type ?? state.type,
                  make: _make,
                  model: _model,
                  color: _color,
                  plate: _plate,
                ),
                hasPhoto:
                    nextPhoto != null || (state.photoPath?.isNotEmpty ?? false),
              )
            : const {},
        failure: failure,
      ),
    );
  }

  void select(VehicleType type) => _change(type: type);
  void change(String field, String value) {
    if (state.isLoading || state.succeeded) return;
    switch (field) {
      case 'make':
        _make = value;
      case 'model':
        _model = value;
      case 'color':
        _color = value;
      case 'plate':
        _plate = value;
    }
    _change();
  }

  void photoSelected(Uint8List bytes, String contentType) {
    _contentType = contentType;
    _change(photo: bytes);
  }

  void photoFailed() => _change(failure: const ServerFailure('photo-picker'));
  Future<void> submit(String uid) async {
    if (state.isLoading || state.succeeded) return;
    final errors = applicationErrors(
      vehicle,
      hasPhoto: state.photo != null || (state.photoPath?.isNotEmpty ?? false),
    );
    if (errors.isNotEmpty) {
      emit(
        DriverOnboardingState(
          type: state.type,
          photo: state.photo,
          photoPath: state.photoPath,
          attempted: true,
          errors: errors,
        ),
      );
      return;
    }
    final previous = state;
    emit(
      DriverOnboardingState(
        type: previous.type,
        photo: previous.photo,
        photoPath: previous.photoPath,
        attempted: true,
        isLoading: true,
      ),
    );
    var path = previous.photoPath;
    if (previous.photo != null) {
      final result = await _upload(uid, previous.photo!, _contentType);
      if (isClosed) return;
      Failure? failure;
      result.fold((value) => failure = value, (value) => path = value);
      if (failure != null) {
        _finish(previous, failure);
        return;
      }
    }
    final result = await _submit(uid, vehicle, path!);
    if (isClosed) return;
    result.fold(
      (failure) => _finish(previous, failure, path: path),
      (_) => emit(
        DriverOnboardingState(
          type: previous.type,
          photo: previous.photo,
          photoPath: path,
          attempted: true,
          succeeded: true,
        ),
      ),
    );
  }

  void _finish(
    DriverOnboardingState previous,
    Failure? failure, {
    String? path,
  }) => emit(
    DriverOnboardingState(
      type: previous.type,
      photo: previous.photo,
      photoPath: path ?? previous.photoPath,
      attempted: true,
      failure: failure,
    ),
  );
}
