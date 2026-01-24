import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/services/auth_controller.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/role_provider.dart';
import '../../shared/utils/theme_provider.dart';
import '../../shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final ProviderSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = ref.listenManual(authControllerProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/auth');
          }
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).loadBiometricState();
    });
  }

  @override
  void dispose() {
    _authSub.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final themeMode = ref.watch(themeModeProvider);
    final role = ref.watch(selectedRoleProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'sign_in')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(appLocaleProvider.notifier).state =
                  locale.languageCode == 'en'
                      ? const Locale('am')
                      : const Locale('en');
            },
          ),
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1E3F), Color(0xFFCDAA80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(locale, 'sign_in'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(locale, 'welcome_back'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (role != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(_roleLabel(t, locale, role)),
                backgroundColor: const Color(0xFF0F1E3F).withOpacity(0.1),
              ),
            ),
          if (role == null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(t(locale, 'choose_role')),
                subtitle: Text(t(locale, 'role_explainer')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/role'),
              ),
            ),
          if (role != null) const SizedBox(height: 12),
          if (authState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t(locale, 'auth_error'),
                      style: const TextStyle(color: Color(0xFFB91C1C)),
                    ),
                  ),
                ],
              ),
            ),
          if (authState.error != null) const SizedBox(height: 12),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t(locale, 'email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t(locale, 'email_required');
                    }
                    if (!value.contains('@')) {
                      return t(locale, 'invalid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t(locale, 'password_optional'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: t(locale, 'sign_in'),
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(authControllerProvider.notifier).loginWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            role: role,
                          );
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata),
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          if (role == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t(locale, 'choose_role_first')),
                              ),
                            );
                            return;
                          }
                          ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle(role: role);
                        },
                  label: Text(t(locale, 'continue_with_google')),
                ),
                if (authState.biometricAvailable)
                  SwitchListTile(
                    title: Text(t(locale, 'enable_biometrics')),
                    value: authState.biometricEnabled,
                    onChanged: authState.isLoading
                        ? null
                        : (value) {
                            ref
                                .read(authControllerProvider.notifier)
                                .setBiometricEnabled(value);
                          },
                  ),
                if (authState.biometricAvailable &&
                    authState.biometricEnabled)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .authenticateWithBiometrics();
                          },
                    label: Text(t(locale, 'use_biometrics')),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t(locale, 'register')),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(t(locale, 'sign_up')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(Function tr, Locale locale, UserRole role) {
    return switch (role) {
      UserRole.seeker => tr(locale, 'seeker'),
      UserRole.donor => tr(locale, 'donor'),
      UserRole.orgRep => tr(locale, 'org_rep'),
    };
  }
}


