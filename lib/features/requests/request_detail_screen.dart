import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/aid_request.dart';
import '../../core/models/enums.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_timeline.dart';
import '../../shared/widgets/urgent_food_banner.dart';
import '../donor/offer_aid_screen.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({
    super.key,
    required this.request,
    required this.isSeeker,
  });

  final AidRequest request;
  final bool isSeeker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(request.type.name.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (request.isUrgentFood) UrgentFoodBanner(request: request),
          if (request.isUrgentFood) const SizedBox(height: 12),
          Text(request.quantity, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(request.description),
          const SizedBox(height: 12),
          _InfoRow(label: t(locale, 'deadline'), value: Formatters.formatDateTime(request.deadline)),
          const SizedBox(height: 4),
          _InfoRow(
            label: t(locale, 'status'),
            value: _statusLabel(locale, request.status),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'status_timeline'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          StatusTimeline(
            steps: [
              t(locale, 'status_draft'),
              t(locale, 'status_submitted'),
              t(locale, 'status_verified'),
              t(locale, 'status_matched'),
              t(locale, 'status_in_progress'),
              t(locale, 'status_completed'),
            ],
            currentIndex: _statusIndex(request.status),
          ),
          const SizedBox(height: 16),
          if (isSeeker && request.status == RequestStatus.inProgress)
            PrimaryButton(
              label: t(locale, 'confirm_receipt'),
              onPressed: () {
                ref
                    .read(requestsControllerProvider.notifier)
                    .confirmReceipt(request.id);
                Navigator.of(context).pop();
              },
            ),
          if (!isSeeker)
            PrimaryButton(
              label: t(locale, 'offer_aid'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OfferAidScreen(request: request),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  int _statusIndex(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return 0;
      case RequestStatus.submitted:
        return 1;
      case RequestStatus.verified:
        return 2;
      case RequestStatus.matched:
        return 3;
      case RequestStatus.inProgress:
        return 4;
      case RequestStatus.completed:
        return 5;
      case RequestStatus.expired:
        return 5;
    }
  }

  String _statusLabel(Locale locale, RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return AppLocalizations.tr(locale, 'status_draft');
      case RequestStatus.submitted:
        return AppLocalizations.tr(locale, 'status_submitted');
      case RequestStatus.verified:
        return AppLocalizations.tr(locale, 'status_verified');
      case RequestStatus.matched:
        return AppLocalizations.tr(locale, 'status_matched');
      case RequestStatus.inProgress:
        return AppLocalizations.tr(locale, 'status_in_progress');
      case RequestStatus.completed:
        return AppLocalizations.tr(locale, 'status_completed');
      case RequestStatus.expired:
        return AppLocalizations.tr(locale, 'status_completed');
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

