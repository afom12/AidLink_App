import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';

class ImpactHistoryScreen extends ConsumerStatefulWidget {
  const ImpactHistoryScreen({super.key});

  @override
  ConsumerState<ImpactHistoryScreen> createState() =>
      _ImpactHistoryScreenState();
}

class _ImpactHistoryScreenState extends ConsumerState<ImpactHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(aidRequestServiceProvider).fetchMyOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'impact_history'))),
      body: EmptyState(
        title: t(locale, 'no_offers'),
        subtitle: t(locale, 'offer_aid'),
      ),
    );
  }
}

