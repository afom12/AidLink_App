import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/services/service_providers.dart';
import '../donor/donor_home_screen.dart';
import '../seeker/seeker_home_screen.dart';
import 'login_screen.dart';
import 'profile_completion_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _bootstrapped = false;
  bool _forceLogin = false;
  Timer? _loadingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      _loadingTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() => _forceLogin = true);
        }
      });
      ref.read(authControllerProvider.notifier).restoreSession();
      ref.read(notificationServiceProvider).initialize();
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isLoading && !_forceLogin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.user;
    if (user == null) {
      return const LoginScreen();
    }

    if (user.needsProfileCompletion) {
      return const ProfileCompletionScreen();
    }

    switch (user.role) {
      case UserRole.seeker:
        return const SeekerHomeScreen();
      case UserRole.donor:
        return const DonorHomeScreen();
      case UserRole.orgRep:
        return const SeekerHomeScreen();
    }
  }
}

