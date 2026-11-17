import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/admin/data/admin_record_model.dart';

void main() {
  // Firestore on the web hands back nested maps as Map<dynamic, dynamic>; a
  // direct `as Map<String, dynamic>` cast broke the admin pricing page there.
  test('adminMap copies web-style dynamic maps', () {
    final web = <dynamic, dynamic>{'base': 0.5, 'perKm': 0.3};
    expect(adminMap(web), {'base': 0.5, 'perKm': 0.3});
    expect(adminMap(web), isA<Map<String, dynamic>>());
  });
  test('adminMap tolerates missing or non-map values', () {
    expect(adminMap(null), isEmpty);
    expect(adminMap('x'), isEmpty);
  });
}
