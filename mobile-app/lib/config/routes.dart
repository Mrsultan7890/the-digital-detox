import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/task_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/leaderboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && state.matchedLocation == '/login') return '/home';
      if (isAuthenticated && state.matchedLocation == '/register') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/categories/:categoryId',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return CategoriesScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/task/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
});

// Keep AppRouter for backward compatibility
class AppRouter {
  static GoRouter get router => throw UnimplementedError('Use routerProvider instead');
}
