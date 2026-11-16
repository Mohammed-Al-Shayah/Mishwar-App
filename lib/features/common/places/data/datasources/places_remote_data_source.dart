import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/places/data/models/place_models.dart';

@lazySingleton
class PlacesRemoteDataSource {
  const PlacesRemoteDataSource(this._functions);
  final FirebaseFunctions _functions;
  Future<List<PlaceSuggestionModel>> search(Map<String, dynamic> data) async {
    final result = await _functions
        .httpsCallable('placesAutocomplete')
        .call<Map<String, dynamic>>(data);
    return (result.data['suggestions'] as List<dynamic>)
        .map(
          (value) => PlaceSuggestionModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        )
        .toList();
  }

  Future<PlaceDetailsModel> details(Map<String, dynamic> data) async {
    final result = await _functions
        .httpsCallable('placeDetails')
        .call<Map<String, dynamic>>(data);
    return PlaceDetailsModel.fromJson(result.data);
  }
}
