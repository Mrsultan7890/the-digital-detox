import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';

final taskDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, taskId) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getTask(taskId);
});

class TaskScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  final _answerController = TextEditingController();
  int _hintsUsed = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  int _pointsEarned = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _currentHint;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    _timer?.cancel();

    await ref.read(taskProvider.notifier).submitAnswer(
      widget.taskId,
      _answerController.text.trim(),
      timeTaken: _elapsedSeconds,
    );

    final result = ref.read(taskProvider).submitResult;
    if (result != null) {
      setState(() {
        _showResult = true;
        _isCorrect = result['correct'] as bool? ?? false;
        _pointsEarned = result['pointsEarned'] as int? ?? 0;
      });
    }
  }

  Future<void> _getHint(int hintLevel) async {
    try {
      final result = await ref.read(taskProvider.notifier).getHint(widget.taskId, hintLevel);
      setState(() {
        _currentHint = result['hint'] as String?;
        _hintsUsed++;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFFf39c12)),
                const SizedBox(width: 8),
                Text('Hint $_hintsUsed'),
              ],
            ),
            content: Text(_currentHint ?? 'No hint available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formattedTime),
        centerTitle: true,
        actions: [
          if (!_showResult)
            TextButton.icon(
              onPressed: _hintsUsed < 3 ? () => _getHint(_hintsUsed + 1) : null,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text('Hint (${3 - _hintsUsed} left)'),
            ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (task) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTaskHeader(task),
              const SizedBox(height: 24),
              _buildQuestionCard(task),
              const SizedBox(height: 24),
              if (!_showResult) ...[
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  onSubmitted: (_) => _submitAnswer(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: taskState.isLoading ? null : _submitAnswer,
                  child: taskState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Answer'),
                ),
              ],
              if (_showResult) ...[
                _buildResultCard(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect
                        ? const Color(0xFF2ecc71)
                        : const Color(0xFF6C63FF),
                  ),
                  child: Text(_isCorrect ? 'Continue 🎉' : 'Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Map<String, dynamic> task) {
    final difficulty = task['difficulty'] as String? ?? 'beginner';
    return Card(
      color: const Color(0xFF6C63FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${task['points_reward'] ?? 10} Points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                difficulty,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] as String? ?? 'Task',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (task['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                task['description'] as String,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const Divider(height: 24),
            Text(
              task['question'] as String? ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: _isCorrect ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrect ? 'Correct! Well done! 🎉' : 'Incorrect. Try again! 💪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (_isCorrect && _pointsEarned > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+$_pointsEarned points earned!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
