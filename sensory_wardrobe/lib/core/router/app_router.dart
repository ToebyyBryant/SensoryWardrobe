import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// A Listenable that notifies GoRouter to re-evaluate redirects
/// whenever auth state or active profile changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(activeProfileProvider, (_, __) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final firebaseUser = authState.valueOrNull;
      final activeProfile = ref.read(activeProfileProvider);

      // Still loading auth — don't redirect yet
      if (authState.isLoading) return null;

      // Firebase user exists but local profile not loaded yet — trigger load
      if (firebaseUser != null && activeProfile == null) {
        ref.read(activeProfileProvider.notifier).loadProfile(firebaseUser.uid);
        // Don't redirect while profile is loading
        return null;
      }

      final isLoggedIn = firebaseUser != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Not logged in → force to login (unless already there)
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in but on auth route → send to dashboard
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
});
