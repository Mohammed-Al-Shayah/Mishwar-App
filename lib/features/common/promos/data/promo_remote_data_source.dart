import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/promos/data/promo_quote_model.dart';

@lazySingleton
class PromoRemoteDataSource {
  const PromoRemoteDataSource(this._functions);
  final FirebaseFunctions _functions;
  Future<PromoQuoteModel> validate(Map<String, dynamic> data) async =>
      PromoQuoteModel.fromJson(
        (await _functions
                .httpsCallable('validatePromo')
                .call<Map<String, dynamic>>(data))
            .data,
      );
}
