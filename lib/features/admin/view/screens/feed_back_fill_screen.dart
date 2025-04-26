import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedBackfillScreen extends ConsumerStatefulWidget {
  const FeedBackfillScreen({Key? key}) : super(key: key);

  @override
  _FeedBackfillScreenState createState() => _FeedBackfillScreenState();
}

class _FeedBackfillScreenState extends ConsumerState<FeedBackfillScreen> {
  bool _isRunning = false;
  String _statusMessage = 'Ready to start feed backfill process';
  String? _lastProcessedUid;
  int _totalProcessed = 0;
  final int _batchSize = 50;
  final ScrollController _logController = ScrollController();
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add("[${DateTime.now().toString()}] $message");

      // Keep scroll at bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logController.hasClients) {
          _logController.animateTo(
            _logController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _startBackfill() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _statusMessage = 'Starting backfill process...';
    });

    _addLog('Starting feed backfill process');

    try {
      bool isComplete = false;

      while (!isComplete) {
        final result = await _processNextBatch();
        isComplete = result['complete'] ?? false;

        if (!mounted) break; // Check if widget is still in the tree
      }

      setState(() {
        _isRunning = false;
        _statusMessage = 'Backfill complete! Processed $_totalProcessed users.';
      });

      _addLog('Backfill process completed successfully');
    } catch (e) {
      setState(() {
        _isRunning = false;
        _statusMessage = 'Error: ${e.toString()}';
      });

      _addLog('Error during backfill: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _processNextBatch() async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('retroactivelyFillUserFeeds');

    _addLog(
        'Processing batch starting from: ${_lastProcessedUid ?? "beginning"}');

    final result = await callable.call({
      'batchSize': _batchSize,
      'startAfterUid': _lastProcessedUid,
    });

    final data = result.data;
    final processedCount = data['processedCount'] ?? 0;
    _lastProcessedUid = data['lastProcessedUid'];
    _totalProcessed += (processedCount as num).toInt();

    setState(() {
      _statusMessage =
          'Processed $processedCount users in this batch. Total: $_totalProcessed';
    });

    _addLog('Batch complete: $processedCount users processed');

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed Backfill Tool')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Feed Backfill Tool',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This tool will populate user feeds with posts from accounts they follow, even if they followed those accounts before the feed system was implemented.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 16),
                    Text('Total Users Processed: $_totalProcessed'),
                    Text('Batch Size: $_batchSize'),
                    if (_lastProcessedUid != null)
                      Text('Last Processed User ID: $_lastProcessedUid'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isRunning ? null : _startBackfill,
                      child: Text(_isRunning ? 'Running...' : 'Start Backfill'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Log section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Process Log',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            controller: _logController,
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Text(
                                _logs[index],
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
