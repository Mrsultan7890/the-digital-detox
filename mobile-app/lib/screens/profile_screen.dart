import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadAll();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final progress = profileState.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(userProfileProvider.notifier).loadAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF6C63FF),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?['display_name'] as String? ?? 'Player',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${profile?['username'] ?? ''}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          '${profile?['total_points'] ?? 0}',
                          'Total Points',
                          Icons.stars,
                        ),
                        _buildStatCard(
                          '${progress?['totalTasksCompleted'] ?? 0}',
                          'Completed',
                          Icons.check_circle,
                        ),
                        _buildStatCard(
                          '${profile?['longest_streak'] ?? 0}',
                          'Best Streak',
                          Icons.local_fire_department,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStreakCard(profile),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(profileState.achievements),
                    const SizedBox(height: 24),
                    _buildProgressSection(progress),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(Map<String, dynamic>? profile) {
    final currentStreak = profile?['current_streak'] as int? ?? 0;
    final hintCoins = profile?['hint_coins'] as int? ?? 0;

    return Card(
      color: const Color(0xFF6C63FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                Text(
                  '$currentStreak Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 50, color: Colors.white30),
            Column(
              children: [
                const Text('💡', style: TextStyle(fontSize: 32)),
                Text(
                  '$hintCoins Hint Coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    if (achievements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No achievements yet. Keep playing!')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: achievements.map((a) {
                final unlocked = a['unlocked'] == 1;
                return _buildBadge(
                  a['icon'] as String? ?? '🏆',
                  a['name'] as String,
                  unlocked,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String name, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFF6C63FF) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: unlocked ? null : Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Map<String, dynamic>? progress) {
    final categoriesProgress = (progress?['categoriesProgress'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    if (categoriesProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categoriesProgress.map((cat) {
              final completed = cat['completed'] as int? ?? 0;
              final total = cat['total'] as int? ?? 1;
              final progressValue = total > 0 ? completed / total : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cat['icon'] ?? ''} ${cat['category_name'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$completed/$total',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
