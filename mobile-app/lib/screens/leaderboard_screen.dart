import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getLeaderboard();
  return (response['leaderboard'] as List).map((e) => e as Map<String, dynamic>).toList();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Error: $error'),
              TextButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return const Center(
              child: Text('No players yet. Be the first!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(leaderboardProvider),
            child: Column(
              children: [
                if (leaderboard.length >= 3)
                  _buildTopThree(leaderboard.take(3).toList()),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final player = leaderboard[index];
                      final isCurrentUser =
                          player['username'] == currentUser?['username'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isCurrentUser
                            ? const Color(0xFF6C63FF).withOpacity(0.1)
                            : null,
                        child: ListTile(
                          leading: _buildRankBadge(
                              (player['rank'] as int?) ?? index + 1),
                          title: Row(
                            children: [
                              Text(
                                player['display_name'] as String? ??
                                    player['username'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle:
                              Text('@${player['username']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars,
                                      color: Color(0xFFf39c12), size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${player['total_points'] ?? 0}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                '${player['tasks_completed'] ?? 0} tasks',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<Map<String, dynamic>> topPlayers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topPlayers.length > 1) _buildPodium(topPlayers[1], 60, '🥈'),
          if (topPlayers.isNotEmpty) _buildPodium(topPlayers[0], 80, '🥇'),
          if (topPlayers.length > 2) _buildPodium(topPlayers[2], 50, '🥉'),
        ],
      ),
    );
  }

  Widget _buildPodium(Map<String, dynamic> player, double height, String medal) {
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Text(
            (player['display_name'] as String? ?? 'P')[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player['display_name'] as String? ?? player['username'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          '${player['total_points'] ?? 0} pts',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    if (rank == 1) color = const Color(0xFFFFD700);
    else if (rank == 2) color = const Color(0xFFC0C0C0);
    else if (rank == 3) color = const Color(0xFFCD7F32);
    else color = const Color(0xFF6C63FF);

    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        '$rank',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
