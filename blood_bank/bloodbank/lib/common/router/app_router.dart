import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bloodbank/features/auth/presentation/providers/auth_provider.dart';
import 'package:bloodbank/features/dashboard/presentation/dashboard_screen.dart';
import 'package:bloodbank/features/requests/presentation/request_screen.dart';
import 'package:bloodbank/features/auth/presentation/login_screen.dart';
import 'package:bloodbank/features/auth/presentation/register_screen.dart';
import 'package:bloodbank/features/awareness/presentation/awareness_screen.dart';
import 'package:bloodbank/features/assistant/presentation/assistant_screen.dart';
import 'package:bloodbank/features/profile/presentation/profile_screen.dart';
import 'package:bloodbank/features/settings/presentation/settings_screen.dart';
import 'package:bloodbank/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:bloodbank/common/widgets/custom_bottom_nav_bar.dart';

class AppRouter {
  final AuthProvider authProvider;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  
  AppRouter(this.authProvider);

  late final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthPage = state.uri.path == '/login' || state.uri.path == '/register';
      
      // If not logged in and not on auth page, redirect to login
      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }
      
      // If logged in and on auth page, redirect to appropriate dashboard
      if (isLoggedIn && isAuthPage) {
        return authProvider.isAdmin ? '/dashboard' : '/requests';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Main Shell (for bottom navigation)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          return Scaffold(
            body: child,
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _getCurrentIndex(state.uri.toString()),
              isAdmin: authProvider.isAdmin,
            ),
          );
        },
        routes: [
          // Admin Dashboard (only accessible to admins)
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (!authProvider.isAdmin) {
                return RequestScreen(userId: authProvider.userId ?? 'anonymous');
              }
              return const NewDashboardScreen();
            },
          ),

          // Regular user routes
          GoRoute(
            path: '/requests',
            builder: (context, state) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              return RequestScreen(userId: authProvider.userId ?? 'anonymous');
            },
          ),
          GoRoute(
            path: '/awareness',
            builder: (context, state) => const AwarenessCenterScreen(),
          ),
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const AssistantScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Admin-only routes
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (!authProvider.isAdmin) {
                return RequestScreen(userId: authProvider.userId ?? 'anonymous');
              }
              return const SettingsScreen();
            },
          ),
        ],
      ),
    ],
  );

  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/requests')) return 0;
    if (location.startsWith('/awareness')) return 1;
    if (location.startsWith('/assistant')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }
}
