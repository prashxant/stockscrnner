import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/stock_detail.dart';

class StockRepository {
  final ApiClient apiClient;

  StockRepository({required this.apiClient});

  Future<StockDetail> getStockDetail(String symbol) async {
    final response = await apiClient.get('/stocks/$symbol');
    return StockDetail.fromJson(response.data);
  }

  Future<List<ChartDataPoint>> getStockChart(String symbol, String timeframe) async {
    final response = await apiClient.get('/stocks/$symbol/chart', queryParameters: {'timeframe': timeframe});
    final dataList = response.data['data'] as List;
    return dataList.map((e) => ChartDataPoint.fromJson(e)).toList();
  }
}

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StockRepository(apiClient: apiClient);
});
