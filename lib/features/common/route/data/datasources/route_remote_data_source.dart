import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/route/data/models/route_models.dart';

@lazySingleton
class RouteRemoteDataSource {
  const RouteRemoteDataSource(this._functions);
  final FirebaseFunctions _functions;
  Future<FareEstimatesModel> estimates(Map<String, dynamic> data) async {
    final result = await _functions
        .httpsCallable('getFareEstimates')
        .call<Map<String, dynamic>>(data);
    return FareEstimatesModel.fromJson(result.data);
  }
}
