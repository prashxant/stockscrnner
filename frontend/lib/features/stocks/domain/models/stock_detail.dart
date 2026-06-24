class StockDetail {
  final String symbol;
  final String name;
  final String exchange;
  final String country;
  final double price;
  final double change;
  final double changePercent;
  final StockFundamentals? fundamentals;
  final List<StockFinancial> financials;

  StockDetail({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.country,
    required this.price,
    required this.change,
    required this.changePercent,
    this.fundamentals,
    required this.financials,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      symbol: json['symbol'],
      name: json['name'],
      exchange: json['exchange'],
      country: json['country'],
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      fundamentals: json['fundamentals'] != null ? StockFundamentals.fromJson(json['fundamentals']) : null,
      financials: json['financials'] != null 
          ? (json['financials'] as List).map((e) => StockFinancial.fromJson(e)).toList() 
          : [],
    );
  }
}

class StockFundamentals {
  final double? peRatio;
  final double? marketCap;
  final double? dividendYield;
  final double? high52Week;
  final double? low52Week;
  final double? roe;

  StockFundamentals({
    this.peRatio,
    this.marketCap,
    this.dividendYield,
    this.high52Week,
    this.low52Week,
    this.roe,
  });

  factory StockFundamentals.fromJson(Map<String, dynamic> json) {
    return StockFundamentals(
      peRatio: json['peRatio'] != null ? (json['peRatio'] as num).toDouble() : null,
      marketCap: json['marketCap'] != null ? (json['marketCap'] as num).toDouble() : null,
      dividendYield: json['dividendYield'] != null ? (json['dividendYield'] as num).toDouble() : null,
      high52Week: json['high52Week'] != null ? (json['high52Week'] as num).toDouble() : null,
      low52Week: json['low52Week'] != null ? (json['low52Week'] as num).toDouble() : null,
      roe: json['roe'] != null ? (json['roe'] as num).toDouble() : null,
    );
  }
}

class StockFinancial {
  final int year;
  final double? revenue;
  final double? netIncome;

  StockFinancial({required this.year, this.revenue, this.netIncome});

  factory StockFinancial.fromJson(Map<String, dynamic> json) {
    return StockFinancial(
      year: json['year'],
      revenue: json['revenue'] != null ? (json['revenue'] as num).toDouble() : null,
      netIncome: json['netIncome'] != null ? (json['netIncome'] as num).toDouble() : null,
    );
  }
}

class ChartDataPoint {
  final DateTime date;
  final double price;

  ChartDataPoint({required this.date, required this.price});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: DateTime.parse(json['date']),
      price: (json['price'] as num).toDouble(),
    );
  }
}
