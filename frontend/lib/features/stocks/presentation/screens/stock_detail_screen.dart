import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stock_provider.dart';

class StockDetailScreen extends ConsumerWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(stockDetailProvider(symbol));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border_rounded),
            tooltip: 'Add to watchlist',
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: detailState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (stock) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${stock.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: stock.change >= 0
                                    ? const Color(0x1A22C55E)
                                    : const Color(0x1AF43F5E),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${stock.change >= 0 ? '+' : ''}${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: stock.change >= 0
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChartSection(ref, symbol),
                const SizedBox(height: 24),
                if (stock.fundamentals != null) ...[
                  Text(
                    'Fundamentals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFundamentalsGrid(stock.fundamentals!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(WidgetRef ref, String symbol) {
    final chartState = ref.watch(stockChartProvider(symbol));
    final timeframe = ref.watch(chartTimeframeProvider);
    final colorScheme = Theme.of(ref.context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Chart',
          style: Theme.of(
            ref.context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '1W', label: Text('1W')),
            ButtonSegment(value: '1M', label: Text('1M')),
            ButtonSegment(value: '3M', label: Text('3M')),
            ButtonSegment(value: '1Y', label: Text('1Y')),
          ],
          selected: {timeframe},
          onSelectionChanged: (Set<String> newSelection) {
            ref.read(chartTimeframeProvider.notifier).state =
                newSelection.first;
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 250,
              child: chartState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    const Center(child: Text('Chart Error')),
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text('No chart data'));
                  }

                  final minY =
                      data.map((e) => e.price).reduce((a, b) => a < b ? a : b) *
                      0.95;
                  final maxY =
                      data.map((e) => e.price).reduce((a, b) => a > b ? a : b) *
                      1.05;

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (data.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(e.key.toDouble(), e.value.price),
                              )
                              .toList(),
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundamentalsGrid(dynamic fundamentals) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildInfoTile(
          'P/E Ratio',
          fundamentals.peRatio?.toStringAsFixed(2) ?? '-',
        ),
        _buildInfoTile(
          'Market Cap',
          '${(fundamentals.marketCap! / 1000000000).toStringAsFixed(2)}B',
        ),
        _buildInfoTile(
          'Div Yield',
          '${fundamentals.dividendYield?.toStringAsFixed(2)}%',
        ),
        _buildInfoTile('ROE', '${fundamentals.roe?.toStringAsFixed(2)}%'),
        _buildInfoTile(
          '52W High',
          fundamentals.high52Week?.toStringAsFixed(2) ?? '-',
        ),
        _buildInfoTile(
          '52W Low',
          fundamentals.low52Week?.toStringAsFixed(2) ?? '-',
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
