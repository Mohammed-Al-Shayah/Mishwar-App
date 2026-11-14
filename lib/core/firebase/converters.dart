import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

export 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint, Timestamp;

/// Firestore snapshot boundary for data models.
typedef FirestoreDocument = DocumentSnapshot<Map<String, dynamic>>;

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();
  @override
  DateTime fromJson(Timestamp json) => json.toDate().toUtc();
  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

class GeoPointConverter implements JsonConverter<GeoPointValue, GeoPoint> {
  const GeoPointConverter();
  @override
  GeoPointValue fromJson(GeoPoint json) =>
      GeoPointValue(json.latitude, json.longitude);
  @override
  GeoPoint toJson(GeoPointValue object) => GeoPoint(object.lat, object.lng);
}
