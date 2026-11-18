import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';

part 'app_service_model.freezed.dart';
part 'app_service_model.g.dart';

@freezed
abstract class AppServiceModel with _$AppServiceModel {
  const factory AppServiceModel({
    required ServiceId id,
    required bool enabled,
    required int order,
  }) = _AppServiceModel;
  const AppServiceModel._();
  factory AppServiceModel.fromJson(Map<String, dynamic> json) =>
      _$AppServiceModelFromJson(json);
  AppService toEntity() => AppService(id: id, enabled: enabled, order: order);
  static List<AppService> parseServices(Map<String, dynamic>? data) {
    final raw = data?['services'];
    if (raw == null) return AppService.defaults;
    if (raw is! List) throw const FormatException('services');
    final services = raw
        .map(
          (value) => AppServiceModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ).toEntity(),
        )
        .toList();
    if (services.length != ServiceId.values.length ||
        services.map((s) => s.id).toSet().length != ServiceId.values.length) {
      throw const FormatException('services');
    }
    return services..sort((a, b) {
      final order = a.order.compareTo(b.order);
      return order == 0 ? a.id.index.compareTo(b.id.index) : order;
    });
  }
}
