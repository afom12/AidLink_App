import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/primary_button.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  int _rating = 4;
  String _category = 'general';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'feedback'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t(locale, 'feedback_prompt'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(labelText: t(locale, 'category')),
                  items: [
                    DropdownMenuItem(
                      value: 'general',
                      child: Text(t(locale, 'category_general')),
                    ),
                    DropdownMenuItem(
                      value: 'bug',
                      child: Text(t(locale, 'category_bug')),
                    ),
                    DropdownMenuItem(
                      value: 'feature',
                      child: Text(t(locale, 'category_feature')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: t(locale, 'feedback_message'),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().length < 8
                      ? t(locale, 'feedback_message_hint')
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text(t(locale, 'feedback_rating'))),
                    _RatingSelector(
                      rating: _rating,
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: t(locale, 'email_optional')),
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        !value.contains('@')) {
                      return t(locale, 'invalid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: t(locale, 'submit'),
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          final sentMessage = t(locale, 'feedback_sent');
                          final errorMessage = t(locale, 'feedback_error');
                          setState(() => _isSubmitting = true);
                          try {
                            await ref.read(feedbackServiceProvider).submitFeedback(
                                  message: _messageController.text.trim(),
                                  rating: _rating,
                                  category: _category,
                                  userId: authState.user?.id,
                                  email: _emailController.text.trim().isEmpty
                                      ? null
                                      : _emailController.text.trim(),
                                );
                            if (mounted) {
                              _messageController.clear();
                              _emailController.clear();
                              messenger.showSnackBar(
                                SnackBar(content: Text(sentMessage)),
                              );
                            }
                          } catch (_) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
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

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = value <= rating;
        return IconButton(
          onPressed: () => onChanged(value),
          icon: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey,
          ),
        );
      }),
    );
  }
}

