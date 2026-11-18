import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';
part 'trusted_contact_model.freezed.dart';
part 'trusted_contact_model.g.dart';

@freezed
abstract class TrustedContactModel with _$TrustedContactModel {
  const factory TrustedContactModel({
    required String id,
    required String name,
    required String phone,
  }) = _TrustedContactModel;
  const TrustedContactModel._();
  factory TrustedContactModel.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactModelFromJson(json);
  TrustedContact toEntity() => TrustedContact(id: id, name: name, phone: phone);
}
