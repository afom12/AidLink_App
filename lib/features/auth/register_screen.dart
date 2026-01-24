import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/services/auth_controller.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/role_provider.dart';
import '../../shared/widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _organizationIdController = TextEditingController();
  final _beneficiaryLocationController = TextEditingController();
  final _householdSizeController = TextEditingController();
  final _donationFocusController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserRole _role = UserRole.seeker;
  String _countryCode = '+251';
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
  }

  @override
  void dispose() {
    _authSub.close();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationNameController.dispose();
    _organizationIdController.dispose();
    _beneficiaryLocationController.dispose();
    _householdSizeController.dispose();
    _donationFocusController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final role = ref.watch(selectedRoleProvider);
    final authState = ref.watch(authControllerProvider);
    final selectedRole = role ?? _role;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'sign_up'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFCDAA80), Color(0xFF0F1E3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(locale, 'create_account'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(locale, 'register_prompt'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: t(locale, 'name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? t(locale, 'name')
                          : null,
                ),
                const SizedBox(height: 16),
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
                    labelText: t(locale, 'password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return t(locale, 'min_password');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: DropdownButtonFormField<String>(
                        value: _countryCode,
                        decoration: InputDecoration(
                          labelText: t(locale, 'country_code'),
                        ),
                        items: const [
                          DropdownMenuItem(value: '+251', child: Text('+251')),
                          DropdownMenuItem(value: '+254', child: Text('+254')),
                          DropdownMenuItem(value: '+1', child: Text('+1')),
                          DropdownMenuItem(value: '+44', child: Text('+44')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _countryCode = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: t(locale, 'phone'),
                          prefixText: '$_countryCode ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 7) {
                            return t(locale, 'phone');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RoleSpecificFields(
                  role: selectedRole,
                  locale: locale,
                  organizationNameController: _organizationNameController,
                  organizationIdController: _organizationIdController,
                  beneficiaryLocationController: _beneficiaryLocationController,
                  householdSizeController: _householdSizeController,
                  donationFocusController: _donationFocusController,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: t(locale, 'create_account'),
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final phone =
                          '$_countryCode${_phoneController.text.trim()}';
                      ref
                          .read(authControllerProvider.notifier)
                          .registerWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            phone: phone,
                            name: _nameController.text.trim(),
                            role: selectedRole,
                            roleData:
                                _buildRoleData(selectedRole, _emailController),
                          );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t(locale, 'already_have_account')),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(t(locale, 'sign_in')),
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

  Map<String, dynamic> _buildRoleData(
    UserRole role,
    TextEditingController emailController,
  ) {
    switch (role) {
      case UserRole.orgRep:
        return {
          'organizationName': _organizationNameController.text.trim(),
          'organizationId': _organizationIdController.text.trim(),
          'contactEmail': emailController.text.trim(),
        };
      case UserRole.seeker:
        return {
          'location': _beneficiaryLocationController.text.trim(),
          'householdSize': int.tryParse(_householdSizeController.text.trim()),
        };
      case UserRole.donor:
        return {
          'donationFocus': _donationFocusController.text.trim(),
        };
    }
  }
}

class _RoleSpecificFields extends StatelessWidget {
  const _RoleSpecificFields({
    required this.role,
    required this.locale,
    required this.organizationNameController,
    required this.organizationIdController,
    required this.beneficiaryLocationController,
    required this.householdSizeController,
    required this.donationFocusController,
  });

  final UserRole role;
  final Locale locale;
  final TextEditingController organizationNameController;
  final TextEditingController organizationIdController;
  final TextEditingController beneficiaryLocationController;
  final TextEditingController householdSizeController;
  final TextEditingController donationFocusController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;

    switch (role) {
      case UserRole.orgRep:
        return Column(
          children: [
            TextFormField(
              controller: organizationNameController,
              decoration: InputDecoration(
                labelText: t(locale, 'organization_name'),
                prefixIcon: const Icon(Icons.apartment_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return t(locale, 'organization_name_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: organizationIdController,
              decoration: InputDecoration(
                labelText: t(locale, 'organization_id'),
                prefixIcon: const Icon(Icons.verified_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t(locale, 'organization_id_required');
                }
                return null;
              },
            ),
          ],
        );
      case UserRole.seeker:
        return Column(
          children: [
            TextFormField(
              controller: beneficiaryLocationController,
              decoration: InputDecoration(
                labelText: t(locale, 'location'),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t(locale, 'location_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: householdSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t(locale, 'household_size'),
                prefixIcon: const Icon(Icons.people_outline),
              ),
            ),
          ],
        );
      case UserRole.donor:
        return TextFormField(
          controller: donationFocusController,
          decoration: InputDecoration(
            labelText: t(locale, 'donation_focus'),
            prefixIcon: const Icon(Icons.favorite_border),
          ),
        );
    }
  }
}

