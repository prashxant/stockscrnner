import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/stock_detail.dart';
import '../../data/repositories/stock_repository.dart';

final stockSymbolProvider = StateProvider<String>((ref) => '');
final chartTimeframeProvider = StateProvider<String>((ref) => '1M');

final stockDetailProvider = FutureProvider.family<StockDetail, String>((ref, symbol) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getStockDetail(symbol);
});

final stockChartProvider = FutureProvider.family<List<ChartDataPoint>, String>((ref, symbol) async {
  final repository = ref.watch(stockRepositoryProvider);
  final timeframe = ref.watch(chartTimeframeProvider);
  return repository.getStockChart(symbol, timeframe);
});
