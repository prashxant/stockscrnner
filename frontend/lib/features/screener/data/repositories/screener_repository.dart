import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class ScreenerRepository {
  final ApiClient apiClient;

  ScreenerRepository({required this.apiClient});

  Future<Map<String, dynamic>> screenStocks({
    required String market,
    required List<Map<String, dynamic>> filters,
    required int page,
    required int limit,
  }) async {
    final response = await apiClient.post(
      '/screener',
      data: {
        'market': market,
        'filters': filters,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }
}

final screenerRepositoryProvider = Provider<ScreenerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScreenerRepository(apiClient: apiClient);
});
