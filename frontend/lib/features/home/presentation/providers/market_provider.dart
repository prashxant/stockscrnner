import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/market_overview.dart';
import '../../data/repositories/market_repository.dart';

final selectedMarketProvider = StateProvider<String>((ref) => 'IN');

final marketOverviewProvider = FutureProvider<MarketOverview>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  final market = ref.watch(selectedMarketProvider);
  
  // Cache the data for 30 seconds after the screen is closed
  final keepAliveLink = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 30), () {
      keepAliveLink.close();
    });
  });
  ref.onResume(() {
    timer?.cancel();
  });

  return repository.getMarketOverview(market);
});
