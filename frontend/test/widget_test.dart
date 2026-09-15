// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhikatti_dataset_collector/data/models/capture_metadata.dart';
import 'package:vazhikatti_dataset_collector/services/validation/metadata_validator.dart';

void main() {
  test('validation blocks incomplete metadata', () {
    expect(MetadataValidator.isReady({'image_path': '/tmp/a.jpg'}), isFalse);
  });

  test('validation accepts complete metadata', () {
    final data = {
      'image_path': '/tmp/a.jpg',
      'latitude': 12.1,
      'longitude': 77.1,
      'gps_accuracy': 8.0,
      'heading': 90.0,
      'pitch': 1.0,
      'roll': 2.0,
      'building_name': 'Engineering Block',
      'floor_number': 'Ground Floor',
      'node_id': 'EB-N-G-001',
      'view_direction': 'Front',
      'dataset_split': 'reference',
    };
    expect(MetadataValidator.isReady(data), isTrue);
  });

  test('canonical metadata round trips and preserves unknown legacy keys', () {
    final original = CaptureMetadata.fromJson({
      'image_id': 'image-1',
      'ISO': 200,
      'view_direction': 'Front',
      'legacy_key': 'retained',
    });
    final restored = CaptureMetadata.fromJson(original.toJson());
    expect(restored.toJson()['image_id'], 'image-1');
    expect(restored.toJson()['ISO'], 200);
    expect(restored.toJson()['legacy_key'], 'retained');
  });
}
