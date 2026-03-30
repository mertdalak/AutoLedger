import 'package:autoledger/features/auth/presentation/login_page.dart';
import 'package:autoledger/features/auth/presentation/register_page.dart';
import 'package:autoledger/features/dashboard/presentation/dashboard_page.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:autoledger/core/router/go_router_refresh_stream.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isAuthPage =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthPage) {
      return '/login';
    }

    if (isLoggedIn && isAuthPage) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
);