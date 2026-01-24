import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../utils/app_localizations.dart';

class AidTypeSelector extends ConsumerWidget {
  const AidTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AidType selected;
  final ValueChanged<AidType> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = AidType.values;
    final locale = ref.watch(appLocaleProvider);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((type) {
        final isActive = type == selected;
        return InkWell(
          onTap: () => onSelected(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                Icon(_iconFor(type), color: isActive ? Colors.blue : Colors.grey),
                const SizedBox(height: 8),
                Text(
                  _labelFor(locale, type),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(AidType type) {
    switch (type) {
      case AidType.food:
        return Icons.fastfood;
      case AidType.clothing:
        return Icons.checkroom;
      case AidType.medical:
        return Icons.medical_services;
      case AidType.cash:
        return Icons.payments;
      case AidType.school:
        return Icons.school;
      case AidType.housing:
        return Icons.home;
      case AidType.ceremony:
        return Icons.celebration;
      case AidType.other:
        return Icons.volunteer_activism;
    }
  }

  String _labelFor(Locale locale, AidType type) {
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
}

