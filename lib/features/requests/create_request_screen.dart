import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/aid_request.dart';
import '../../core/models/enums.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/aid_type_selector.dart';
import '../../shared/widgets/primary_button.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  AidType _type = AidType.food;
  UrgencyLevel _urgency = UrgencyLevel.high;
  bool _perishable = true;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;
  DateTime? _expiry;

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsControllerProvider);
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'new_request'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AidTypeSelector(
            selected: _type,
            onSelected: (value) {
              setState(() => _type = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UrgencyLevel>(
            value: _urgency,
            decoration: InputDecoration(labelText: t(locale, 'urgency')),
            items: UrgencyLevel.values
                .map(
                  (level) => DropdownMenuItem(
                    value: level,
                    child: Text(level.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _urgency = value);
            },
          ),
          const SizedBox(height: 12),
          if (_type == AidType.food)
            SwitchListTile(
              title: Text(t(locale, 'perishable_food')),
              value: _perishable,
              onChanged: (value) => setState(() => _perishable = value),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: t(locale, 'quantity')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(labelText: t(locale, 'description')),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t(locale, 'deadline')),
            subtitle: Text(Formatters.formatDateTime(_deadline)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date == null) return;
              if (!mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(DateTime.now()),
              );
              if (time == null) return;
              setState(() {
                _deadline = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                if (_type == AidType.food && _perishable) {
                  _expiry = _deadline;
                }
              });
            },
          ),
          if (_type == AidType.food && _perishable)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t(locale, 'expiry_time')),
              subtitle: Text(Formatters.formatDateTime(_expiry)),
              trailing: const Icon(Icons.timer),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                );
                if (time == null) return;
                setState(() {
                  final base = _deadline ?? DateTime.now();
                  _expiry = DateTime(
                    base.year,
                    base.month,
                    base.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: t(locale, 'submit_request'),
            isLoading: requestsState.isLoading,
            onPressed: () async {
              if (_type == AidType.food && _deadline == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(locale, 'deadline_required'))),
                );
                return;
              }
              final created = await ref
                  .read(requestsControllerProvider.notifier)
                  .createRequest(
                    AidRequest(
                      id: '',
                      seekerId: '',
                      type: _type,
                      urgency: _urgency,
                      quantity: _quantityController.text.trim(),
                      description: _descriptionController.text.trim(),
                      status: RequestStatus.submitted,
                      createdAt: DateTime.now(),
                      deadline: _deadline,
                      expiryTime: _expiry,
                      isPerishable: _perishable,
                    ),
                  );
              if (!mounted) return;
              if (created != null) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

