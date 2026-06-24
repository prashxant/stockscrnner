import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlists'),
        actions: [
          IconButton(
            tooltip: 'Add watchlist',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Track your curated lists with a cleaner overview.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildWatchlistCard(context, 'Tech Giants', [
              'AAPL',
              'MSFT',
              'NVDA',
            ]),
            const SizedBox(height: 16),
            _buildWatchlistCard(context, 'Indian Bluechips', [
              'RELIANCE',
              'TCS',
              'HDFCBANK',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistCard(
    BuildContext context,
    String title,
    List<String> symbols,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symbols
                  .map(
                    (symbol) => Chip(
                      label: Text(symbol),
                      avatar: Icon(
                        Icons.show_chart_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
