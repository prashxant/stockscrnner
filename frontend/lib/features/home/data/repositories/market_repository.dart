import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/market_overview.dart';

class MarketRepository {
  final ApiClient apiClient;

  MarketRepository({required this.apiClient});

  Future<MarketOverview> getMarketOverview(String market) async {
    final response = await apiClient.get('/market/overview', queryParameters: {'market': market});
    return MarketOverview.fromJson(response.data);
  }
}

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketRepository(apiClient: apiClient);
});
