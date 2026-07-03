import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

final categoryTasksProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, categoryId) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getTasksByCategory(categoryId);
  return (response['tasks'] as List).map((e) => e as Map<String, dynamic>).toList();
});

class CategoriesScreen extends ConsumerWidget {
  final String categoryId;

  const CategoriesScreen({super.key, required this.categoryId});

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner': return const Color(0xFF2ecc71);
      case 'intermediate': return const Color(0xFFf39c12);
      case 'advanced': return const Color(0xFFe74c3c);
      case 'expert': return const Color(0xFF9b59b6);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(categoryTasksProvider(int.parse(categoryId)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Error: $error'),
              TextButton(
                onPressed: () => ref.invalidate(categoryTasksProvider(int.parse(categoryId))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tasks available yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isCompleted = task['completed'] == 1;
              final difficulty = task['difficulty'] as String? ?? 'beginner';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isCompleted
                        ? const Color(0xFF2ecc71)
                        : const Color(0xFF6C63FF),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                            '${task['level_number'] ?? index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                  title: Text(
                    task['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _difficultyColor(difficulty).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(
                            color: _difficultyColor(difficulty),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFf39c12), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${task['points_reward'] ?? 10}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/task/${task['id']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
