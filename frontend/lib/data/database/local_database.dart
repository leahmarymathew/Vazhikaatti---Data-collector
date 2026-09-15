import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/legacy_models.dart';

class LocalDatabase {
  LocalDatabase._();
  static final instance = LocalDatabase._();
  Database? _db;

  Future<Database> get database async => _db ??= await _open();
  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'vazhikatti.sqlite'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE sessions (id TEXT PRIMARY KEY, name TEXT NOT NULL, created_at TEXT NOT NULL, collector_id TEXT NOT NULL, status TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE captures (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, filename TEXT NOT NULL, image_path TEXT NOT NULL, metadata_json TEXT NOT NULL, created_at TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE INDEX captures_session ON captures(session_id)',
        );
      },
    );
    return db;
  }

  Future<void> saveSession(CaptureSession session) async =>
      (await database).insert(
        'sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  Future<List<CaptureSession>> sessions() async => (await database)
      .query('sessions', orderBy: 'created_at DESC')
      .then((rows) => rows.map(CaptureSession.fromMap).toList());
  Future<void> saveCapture(CaptureRecord record) async =>
      (await database).insert(
        'captures',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  Future<List<CaptureRecord>> captures([String? sessionId]) async {
    final rows = await (await database).query(
      'captures',
      where: sessionId == null ? null : 'session_id = ?',
      whereArgs: sessionId == null ? null : [sessionId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CaptureRecord.fromMap).toList();
  }

  Future<int> captureCount() async =>
      Sqflite.firstIntValue(
        await (await database).rawQuery('SELECT COUNT(*) FROM captures'),
      ) ??
      0;
}
