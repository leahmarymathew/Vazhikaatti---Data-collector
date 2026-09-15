import 'package:flutter/material.dart';
import '../../data/database/local_database.dart';
import 'sync_service.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});
  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final service = SyncService();
  Map<String, int> counts = {};
  bool busy = false;
  bool? online;
  String? message;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    counts = await LocalDatabase.instance.syncCounts();
    if (mounted) setState(() {});
  }

  Future<void> sync() async {
    setState(() {
      busy = true;
      message = null;
    });
    final report = await service.syncPending();
    online = report.failed == 0 || report.uploaded > 0;
    message = report.failed == 0
        ? 'Synchronization complete.'
        : 'Some uploads failed. Your local images are safe and can be retried.';
    await refresh();
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Synchronization')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            leading: Icon(
              online == true ? Icons.cloud_done : Icons.cloud_off,
              color: online == true ? Colors.teal : Colors.orange,
            ),
            title: Text(
              online == true ? 'Backend online' : 'Offline or not checked',
            ),
            subtitle: const Text('The phone remains the source of truth.'),
          ),
        ),
        const SizedBox(height: 12),
        _stat('Pending', counts['pending'] ?? 0, Icons.schedule),
        _stat(
          'Uploading',
          counts['uploading'] ?? 0,
          Icons.cloud_upload_outlined,
        ),
        _stat('Uploaded', counts['uploaded'] ?? 0, Icons.check_circle_outline),
        _stat('Failed', counts['failed'] ?? 0, Icons.error_outline),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: busy ? null : sync,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.sync),
          label: const Text('Sync Now'),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(message!),
          ),
      ],
    ),
  );
  Widget _stat(String label, int value, IconData icon) => Card(
    elevation: 0,
    child: ListTile(
      leading: Icon(icon),
      title: Text('$value'),
      subtitle: Text(label),
    ),
  );
}
