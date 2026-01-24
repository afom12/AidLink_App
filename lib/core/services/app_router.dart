import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_gate.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/admin_login_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/dashboard/admin_dashboard.dart';
import '../../features/donor/donor_home_screen.dart';
import '../../features/seeker/seeker_home_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/feedback/feedback_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _fadePage(state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _slidePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/admin-login',
      pageBuilder: (context, state) =>
          _slidePage(state, const AdminLoginScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          _slidePage(state, const RegisterScreen()),
    ),
    GoRoute(
      path: '/role',
      pageBuilder: (context, state) =>
          _fadePage(state, const RoleSelectionScreen()),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => _fadePage(state, const AuthGate()),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _fadePage(state, const AuthGate()),
    ),
    GoRoute(
      path: '/dashboard/seeker',
      pageBuilder: (context, state) =>
          _fadePage(state, const SeekerHomeScreen()),
    ),
    GoRoute(
      path: '/dashboard/donor',
      pageBuilder: (context, state) =>
          _fadePage(state, const DonorHomeScreen()),
    ),
    GoRoute(
      path: '/dashboard/admin',
      pageBuilder: (context, state) =>
          _fadePage(state, const AdminDashboard()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _slidePage(state, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) =>
          _slidePage(state, const AboutScreen()),
    ),
    GoRoute(
      path: '/feedback',
      pageBuilder: (context, state) =>
          _slidePage(state, const FeedbackScreen()),
    ),
    GoRoute(
      path: '/profile/:role',
      pageBuilder: (context, state) => _fadePage(
        state,
        ProfileScreen(role: state.pathParameters['role'] ?? 'seeker'),
      ),
    ),
    GoRoute(
      path: '/profile/:role/edit',
      pageBuilder: (context, state) => _slidePage(
        state,
        EditProfileScreen(role: state.pathParameters['role'] ?? 'seeker'),
      ),
    ),
    GoRoute(
      path: '/profile/:role/settings',
      pageBuilder: (context, state) => _slidePage(
        state,
        SettingsScreen(role: state.pathParameters['role'] ?? 'seeker'),
      ),
    ),
  ],
);

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    child: child,
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    child: child,
  );
}

