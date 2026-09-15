// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:vazhikatti_dataset_collector/data/models/capture_metadata.dart';
import 'package:vazhikatti_dataset_collector/data/models/ground_truth_options.dart';
import 'package:vazhikatti_dataset_collector/services/validation/metadata_validator.dart';

Map<String, dynamic> _completeMetadata() => {
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
  'ground_truth_campus': 'IIIT K',
  'ground_truth_building': 'New Academic Block',
  'ground_truth_floor': 'Ground',
  'ground_truth_node_name': 'Main Entrance',
};

void main() {
  test('validation blocks incomplete metadata', () {
    expect(MetadataValidator.isReady({'image_path': '/tmp/a.jpg'}), isFalse);
  });

  test('validation accepts complete metadata', () {
    expect(MetadataValidator.isReady(_completeMetadata()), isTrue);
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

  group('ground truth dropdown options', () {
    test('campus has exactly one canonical value', () {
      expect(groundTruthCampusOptions, ['IIIT K']);
      expect(defaultGroundTruthCampus, 'IIIT K');
    });

    test('building options match the canonical list exactly', () {
      expect(groundTruthBuildingOptions, [
        'Old Academic Block',
        'New Academic Block',
        'Admin Block',
        'General Pathway',
      ]);
    });

    test('floor options match the canonical list exactly', () {
      expect(groundTruthFloorOptions, ['Basement', 'Ground', '1', '2']);
    });
  });

  group('ground truth validation', () {
    test('missing campus fails validation', () {
      final data = _completeMetadata()..remove('ground_truth_campus');
      expect(MetadataValidator.isReady(data), isFalse);
    });

    test('missing building fails validation', () {
      final data = _completeMetadata()..['ground_truth_building'] = null;
      expect(MetadataValidator.isReady(data), isFalse);
    });

    test('missing floor fails validation', () {
      final data = _completeMetadata()..['ground_truth_floor'] = null;
      expect(MetadataValidator.isReady(data), isFalse);
    });

    test('empty node name fails validation', () {
      final data = _completeMetadata()..['ground_truth_node_name'] = '';
      expect(MetadataValidator.isReady(data), isFalse);
    });

    test('whitespace-only node name fails validation', () {
      final data = _completeMetadata()..['ground_truth_node_name'] = '   ';
      expect(MetadataValidator.isReady(data), isFalse);
    });
  });

  test('ground truth fields survive export field list and JSON round trip', () {
    expect(CaptureMetadata.fields, contains('ground_truth_campus'));
    expect(CaptureMetadata.fields, contains('ground_truth_building'));
    expect(CaptureMetadata.fields, contains('ground_truth_floor'));
    expect(CaptureMetadata.fields, contains('ground_truth_node_name'));

    final metadata = CaptureMetadata.fromJson({
      'image_id': 'image-2',
      'ground_truth_campus': 'IIIT K',
      'ground_truth_building': 'Admin Block',
      'ground_truth_floor': '1',
      'ground_truth_node_name': 'Staircase',
    }).toJson();

    expect(metadata['ground_truth_campus'], 'IIIT K');
    expect(metadata['ground_truth_building'], 'Admin Block');
    expect(metadata['ground_truth_floor'], '1');
    expect(metadata['ground_truth_node_name'], 'Staircase');
  });
}
