import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/aid_request.dart';
import '../../core/models/enums.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/formatters.dart';
import 'urgent_food_banner.dart';

class RequestCard extends ConsumerWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final AidRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (request.isUrgentFood) UrgentFoodBanner(request: request),
              if (request.isUrgentFood) const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _typeLabel(locale, request.type),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (request.distanceKm != null)
                    Text('${request.distanceKm!.toStringAsFixed(1)} km'),
                ],
              ),
              const SizedBox(height: 6),
              Text(request.quantity, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.tr(locale, 'status')}: '
                    '${_statusLabel(locale, request.status)}',
                  ),
                  if (request.deadline != null)
                    Text(
                      '${AppLocalizations.tr(locale, 'due')} '
                      '${Formatters.formatDateTime(request.deadline)}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(Locale locale, AidType type) {
    switch (type) {
      case AidType.food:
        return AppLocalizations.tr(locale, 'aid_food');
      case AidType.clothing:
        return AppLocalizations.tr(locale, 'aid_clothing');
      case AidType.medical:
        return AppLocalizations.tr(locale, 'aid_medical');
      case AidType.cash:
        return AppLocalizations.tr(locale, 'aid_cash');
      case AidType.school:
        return AppLocalizations.tr(locale, 'aid_school');
      case AidType.housing:
        return AppLocalizations.tr(locale, 'aid_housing');
      case AidType.ceremony:
        return AppLocalizations.tr(locale, 'aid_ceremony');
      case AidType.other:
        return AppLocalizations.tr(locale, 'aid_other');
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

