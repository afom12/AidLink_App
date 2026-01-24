import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/aid_request.dart';
import '../utils/app_localizations.dart';
import '../utils/formatters.dart';

class UrgentFoodBanner extends ConsumerStatefulWidget {
  const UrgentFoodBanner({super.key, required this.request});

  final AidRequest request;

  @override
  ConsumerState<UrgentFoodBanner> createState() => _UrgentFoodBannerState();
}

class _UrgentFoodBannerState extends ConsumerState<UrgentFoodBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.request.isUrgentFood) {
      return const SizedBox.shrink();
    }
    final locale = ref.watch(appLocaleProvider);
    final remaining = widget.request.timeRemaining;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.urgent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.urgent),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.urgent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.tr(locale, 'urgent_food'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            Formatters.formatCountdown(remaining),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.urgent),
          ),
        ],
      ),
    );
  }
}

