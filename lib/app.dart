import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/admin/presentation/screens/owner_application_detail_screen.dart';
import 'features/admin/presentation/screens/pending_owners_screen.dart';
import 'features/auth/domain/app_user.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/owner/presentation/screens/ground_editor_route.dart';
import 'features/owner/presentation/screens/ground_editor_screen.dart';
import 'features/owner/presentation/screens/owner_dashboard_screen.dart';
import 'features/owner/presentation/screens/owner_pending_screen.dart';
import 'features/user/presentation/screens/user_home_screen.dart';

class FutsalApp extends ConsumerWidget {
  const FutsalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(currentUserStreamProvider);
    final user = auth.value;
    final isLoading = auth.isLoading;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(
          path: '/register/owner',
          builder: (_, _) => const RegisterScreen(initialTab: 1),
        ),
        GoRoute(
          path: '/register/user',
          builder: (_, _) => const RegisterScreen(initialTab: 0),
        ),
        GoRoute(path: '/pending', builder: (_, _) => const OwnerPendingScreen()),
        GoRoute(
          path: '/owner',
          builder: (_, _) => const OwnerDashboardScreen(),
        ),
        GoRoute(
          path: '/owner/grounds/new',
          builder: (_, _) => const GroundEditorScreen(),
        ),
        GoRoute(
          path: '/owner/grounds/:id/edit',
          builder: (_, state) => GroundEditorRoute(
            groundId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/admin', builder: (_, _) => const PendingOwnersScreen()),
        GoRoute(
          path: '/admin/applications/:id',
          builder: (_, state) => OwnerApplicationDetailScreen(
            applicationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/user', builder: (_, _) => const UserHomeScreen()),
      ],
      redirect: (_, state) {
        final location = state.matchedLocation;
        final authRoutes = [
          '/login',
          '/register',
          '/register/owner',
          '/register/user',
        ];

        if (isLoading) {
          return location == '/splash' ? null : '/splash';
        }

        if (user == null) {
          return authRoutes.contains(location) ? null : '/login';
        }

        final home = _homeFor(user);
        if (location == '/' || location == '/splash') return home;
        if (authRoutes.contains(location)) return home;

        if (user.isAdmin) {
          return location.startsWith('/admin') ? null : home;
        }
        if (user.role == AppRole.owner) {
          if (user.approvalStatus != ApprovalStatus.approved) {
            return location == '/pending' ? null : '/pending';
          }
          return location.startsWith('/owner') ? null : home;
        }
        return location == '/user' ? null : home;
      },
    );

    return MaterialApp.router(
      title: 'Futsal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }

  static String _homeFor(AppUser user) {
    if (user.isAdmin) return '/admin';
    if (user.role == AppRole.owner) {
      return user.isApprovedOwner ? '/owner' : '/pending';
    }
    return '/user';
  }
}
