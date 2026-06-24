import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/screener_repository.dart';

class ScreenerState {
  final List<dynamic> stocks;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isInitialLoading;
  final String error;

  ScreenerState({
    required this.stocks,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isInitialLoading,
    required this.error,
  });

  factory ScreenerState.initial() {
    return ScreenerState(
      stocks: [],
      page: 1,
      hasMore: true,
      isLoadingMore: false,
      isInitialLoading: false,
      error: '',
    );
  }

  ScreenerState copyWith({
    List<dynamic>? stocks,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isInitialLoading,
    String? error,
  }) {
    return ScreenerState(
      stocks: stocks ?? this.stocks,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      error: error ?? this.error,
    );
  }
}

class ScreenerNotifier extends StateNotifier<ScreenerState> {
  final ScreenerRepository _repository;
  final String _market;
  final List<Map<String, dynamic>> _filters;

  ScreenerNotifier(this._repository, this._market, this._filters) : super(ScreenerState.initial()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isInitialLoading: true, error: '');
    try {
      final response = await _repository.screenStocks(
        market: _market,
        filters: _filters,
        page: 1,
        limit: 10,
      );
      final list = response['data'] as List;
      final meta = response['meta'];
      final totalPages = meta['totalPages'] as int;

      state = state.copyWith(
        stocks: list,
        page: 1,
        hasMore: 1 < totalPages,
        isInitialLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isInitialLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final response = await _repository.screenStocks(
        market: _market,
        filters: _filters,
        page: nextPage,
        limit: 10,
      );
      final list = response['data'] as List;
      final meta = response['meta'];
      final totalPages = meta['totalPages'] as int;

      state = state.copyWith(
        stocks: [...state.stocks, ...list],
        page: nextPage,
        hasMore: nextPage < totalPages,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

// Family provider to dynamically screen based on filters
final screenerProvider = StateNotifierProvider.family<ScreenerNotifier, ScreenerState, String>((ref, marketAndFiltersKey) {
  // Parsing simple key like "IN;peRatio:lt:20" for simplicity
  final repository = ref.watch(screenerRepositoryProvider);
  final parts = marketAndFiltersKey.split(';');
  final market = parts[0];
  
  final List<Map<String, dynamic>> filters = [];
  if (parts.length > 1 && parts[1].isNotEmpty) {
    final filterParts = parts[1].split(',');
    for (var f in filterParts) {
      final fieldOpVal = f.split(':');
      if (fieldOpVal.length == 3) {
        filters.add({
          'field': fieldOpVal[0],
          'operator': fieldOpVal[1],
          'value': double.tryParse(fieldOpVal[2]) ?? fieldOpVal[2],
        });
      }
    }
  }

  return ScreenerNotifier(repository, market, filters);
});
