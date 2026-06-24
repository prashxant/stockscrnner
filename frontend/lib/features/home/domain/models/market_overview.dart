class IndexData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;

  IndexData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });

  factory IndexData.fromJson(Map<String, dynamic> json) {
    return IndexData(
      symbol: json['symbol'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
    );
  }
}

class StockSummary {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double volume;

  StockSummary({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      symbol: json['symbol'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }
}

class MarketOverview {
  final List<IndexData> indices;
  final List<StockSummary> topGainers;
  final List<StockSummary> topLosers;
  final List<StockSummary> mostActive;

  MarketOverview({
    required this.indices,
    required this.topGainers,
    required this.topLosers,
    required this.mostActive,
  });

  factory MarketOverview.fromJson(Map<String, dynamic> json) {
    return MarketOverview(
      indices: (json['indices'] as List).map((e) => IndexData.fromJson(e)).toList(),
      topGainers: (json['topGainers'] as List).map((e) => StockSummary.fromJson(e)).toList(),
      topLosers: (json['topLosers'] as List).map((e) => StockSummary.fromJson(e)).toList(),
      mostActive: (json['mostActive'] as List).map((e) => StockSummary.fromJson(e)).toList(),
    );
  }
}
