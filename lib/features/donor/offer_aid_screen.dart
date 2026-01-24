import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/aid_request.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/primary_button.dart';

class OfferAidScreen extends ConsumerStatefulWidget {
  const OfferAidScreen({super.key, required this.request});

  final AidRequest request;

  @override
  ConsumerState<OfferAidScreen> createState() => _OfferAidScreenState();
}

class _OfferAidScreenState extends ConsumerState<OfferAidScreen> {
  final _noteController = TextEditingController();
  DateTime? _availability;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsControllerProvider);
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'offer_aid'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t(locale, 'availability')),
            subtitle: Text(Formatters.formatDateTime(_availability)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date == null) return;
              if (!mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(DateTime.now()),
              );
              if (time == null) return;
              setState(() {
                _availability = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(labelText: t(locale, 'notes_optional')),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: t(locale, 'offer_aid'),
            isLoading: requestsState.isLoading,
            onPressed: () async {
              final offer = await ref
                  .read(requestsControllerProvider.notifier)
                  .offerAid(
                    requestId: widget.request.id,
                    type: widget.request.type,
                    availabilityTime: _availability,
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  );
              if (!mounted) return;
              if (offer != null) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

