import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/screener_provider.dart';

class ScreenerScreen extends ConsumerStatefulWidget {
  const ScreenerScreen({super.key});

  @override
  ConsumerState<ScreenerScreen> createState() => _ScreenerScreenState();
}

class _ScreenerScreenState extends ConsumerState<ScreenerScreen> {
  double _peValue = 50.0;
  double _marketCapValue = 1000.0;
  final ScrollController _scrollController = ScrollController();
  String _activeFilterKey = 'IN;peRatio:lt:50.0,marketCap:gt:1000000000.0';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(screenerProvider(_activeFilterKey).notifier).fetchNextPage();
    }
  }

  void _applyFilters() {
    final marketCapInBytes = _marketCapValue * 1000000000;
    setState(() {
      _activeFilterKey =
          'IN;peRatio:lt:$_peValue,marketCap:gt:$marketCapInBytes';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenerState = ref.watch(screenerProvider(_activeFilterKey));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: isWide
              ? Row(
                  children: [
                    _buildFilterPanel(context),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(child: _buildResultsPanel(context, screenerState)),
                  ],
                )
              : Column(
                  children: [
                    _buildCompactHeader(context),
                    Expanded(child: _buildResultsPanel(context, screenerState)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Refine the universe before you screen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _buildSliderCard(
            context,
            title: 'P/E Ratio',
            valueLabel: 'Under ${_peValue.toInt()}',
            slider: Slider(
              value: _peValue,
              min: 0,
              max: 200,
              onChanged: (val) => setState(() => _peValue = val),
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderCard(
            context,
            title: 'Market Cap',
            valueLabel: 'Above ${_marketCapValue.toInt()}B',
            slider: Slider(
              value: _marketCapValue,
              min: 0,
              max: 3000,
              onChanged: (val) => setState(() => _marketCapValue = val),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('P/E < ${_peValue.toInt()}')),
                  Chip(label: Text('Market Cap > ${_marketCapValue.toInt()}B')),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard(
    BuildContext context, {
    required String title,
    required String valueLabel,
    required Widget slider,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(valueLabel, style: Theme.of(context).textTheme.bodyMedium),
            slider,
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPanel(BuildContext context, ScreenerState screenerState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: screenerState.isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : screenerState.error.isNotEmpty
              ? _buildErrorState(context, screenerState.error)
              : ListView.separated(
                  controller: _scrollController,
                  itemCount:
                      screenerState.stocks.length +
                      (screenerState.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  itemBuilder: (context, index) {
                    if (index == screenerState.stocks.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final stock = screenerState.stocks[index];
                    final symbol = stock['symbol'] as String;
                    final name = stock['name'] as String;
                    final price = stock['price'] as double? ?? 0.0;
                    final peRatio = stock['peRatio'] as double? ?? 0.0;
                    final isPositive = (stock['change'] as double? ?? 0) >= 0;

                    return Card(
                      child: ListTile(
                        onTap: () => context.push('/stock/$symbol'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(
                          symbol,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isPositive
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          child: Icon(
                            isPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'P/E ${peRatio.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load screener results',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _applyFilters, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
