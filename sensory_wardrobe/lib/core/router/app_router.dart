import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_screen.dart';
import '../../features/wardrobe/presentation/screens/add_clothing_item_screen.dart';
import '../../features/outfit_log/presentation/screens/log_outfit_screen.dart';
import '../../features/outfit_log/presentation/screens/comfort_rating_screen.dart';
import '../../features/suggestions/presentation/screens/suggestions_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

part 'app_router.g.dart';

/// Route name constants
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/';
  static const wardrobe = '/wardrobe';
  static const addClothingItem = '/wardrobe/add';
  static const logOutfit = '/log-outfit';
  static const comfortRating = '/log-outfit/rate';
  static const suggestions = '/suggestions';
  static const history = '/history';
  static const settings = '/settings';
  static const profile = '/profile';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);
  final firebaseUser = authState.valueOrNull;
  final activeProfile = ref.watch(activeProfileProvider);

  if (!authState.isLoading && firebaseUser != null && activeProfile == null) {
    ref.read(activeProfileProvider.notifier).loadProfile(firebaseUser.uid);
  }

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = firebaseUser != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.wardrobe,
        builder: (context, state) => const WardrobeScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddClothingItemScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.logOutfit,
        builder: (context, state) => const LogOutfitScreen(),
        routes: [
          GoRoute(
            path: 'rate',
            builder: (context, state) => const ComfortRatingScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.suggestions,
        builder: (context, state) => const SuggestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
