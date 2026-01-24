import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.role});

  final String role;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _countryCode = '+251';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
      _setPhoneFields(user.phone);
    }
  }

  void _setPhoneFields(String phone) {
    const codes = ['+251', '+254', '+1', '+44'];
    for (final code in codes) {
      if (phone.startsWith(code)) {
        _countryCode = code;
        _phoneController.text = phone.substring(code.length).trim();
        return;
      }
    }
    _phoneController.text = phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'edit_profile'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: t(locale, 'name')),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? t(locale, 'name')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: t(locale, 'email')),
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
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: DropdownButtonFormField<String>(
                        value: _countryCode,
                        decoration:
                            InputDecoration(labelText: t(locale, 'country_code')),
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
                        enabled: false,
                        decoration: InputDecoration(labelText: t(locale, 'phone')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: t(locale, 'update_profile'),
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(authControllerProvider.notifier).updateProfile(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim().isEmpty
                                ? null
                                : _emailController.text.trim(),
                            locale: locale.languageCode,
                          );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


