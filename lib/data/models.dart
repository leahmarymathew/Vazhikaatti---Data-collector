import 'dart:convert';

class CaptureSession {
  const CaptureSession({
    required this.id,
    required this.name,
    required this.createdAt,
    this.collectorId = 'local-collector',
    this.status = 'active',
  });
  final String id;
  final String name;
  final DateTime createdAt;
  final String collectorId;
  final String status;
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'collector_id': collectorId,
    'status': status,
  };
  factory CaptureSession.fromMap(Map<String, dynamic> map) => CaptureSession(
    id: map['id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    collectorId: map['collector_id'] as String? ?? 'local-collector',
    status: map['status'] as String? ?? 'active',
  );
}

class CaptureRecord {
  CaptureRecord({
    required this.id,
    required this.sessionId,
    required this.filename,
    required this.imagePath,
    required this.metadata,
    required this.createdAt,
  });
  final String id;
  final String sessionId;
  final String filename;
  final String imagePath;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  Map<String, dynamic> toMap() => {
    'id': id,
    'session_id': sessionId,
    'filename': filename,
    'image_path': imagePath,
    'metadata_json': jsonEncode(metadata),
    'created_at': createdAt.toIso8601String(),
  };
  factory CaptureRecord.fromMap(Map<String, dynamic> map) => CaptureRecord(
    id: map['id'] as String,
    sessionId: map['session_id'] as String,
    filename: map['filename'] as String,
    imagePath: map['image_path'] as String,
    metadata:
        jsonDecode(map['metadata_json'] as String) as Map<String, dynamic>,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

const sampleNodes = <Map<String, dynamic>>[
  {
    'campus': 'Main Campus',
    'building': 'Engineering Block',
    'wing': 'North Wing',
    'floor': 'Ground Floor',
    'area': 'Corridor',
    'node': 'EB-N-G-001',
    'name': 'North Entrance',
  },
  {
    'campus': 'Main Campus',
    'building': 'Engineering Block',
    'wing': 'North Wing',
    'floor': 'First Floor',
    'area': 'Laboratory',
    'node': 'EB-N-1-101',
    'name': 'Computer Vision Lab',
  },
  {
    'campus': 'Main Campus',
    'building': 'Library',
    'wing': 'Central',
    'floor': 'Ground Floor',
    'area': 'Reading Hall',
    'node': 'LIB-C-G-001',
    'name': 'Main Reading Hall',
  },
];
