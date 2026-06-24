import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:stock_screener/core/theme/theme_mode_controller.dart';
import 'package:stock_screener/features/auth/presentation/providers/auth_provider.dart';
import 'package:stock_screener/features/home/domain/models/market_overview.dart';
import 'package:stock_screener/features/home/presentation/providers/market_provider.dart';
import 'package:stock_screener/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:stock_screener/features/screener/presentation/screens/screener_screen.dart';
import 'package:stock_screener/features/watchlist/presentation/screens/watchlist_screen.dart';
import 'package:stock_screener/shared/widgets/global_search_delegate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(marketOverviewProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);
    final themeMode = ref
        .watch(themeModeProvider)
        .maybeWhen(data: (mode) => mode, orElse: () => ThemeMode.system);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Market Pulse'),
            Text(
              selectedMarket == 'IN'
                  ? 'India market watch'
                  : 'United States market watch',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () =>
                showSearch(context: context, delegate: GlobalSearchDelegate()),
          ),
          PopupMenuButton<ThemeMode>(
            tooltip: 'Theme mode',
            initialValue: themeMode,
            icon: Icon(_themeModeIcon(themeMode)),
            onSelected: (mode) =>
                ref.read(themeModeProvider.notifier).setThemeMode(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto_outlined),
                    SizedBox(width: 12),
                    Text('System'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_outlined),
                    SizedBox(width: 12),
                    Text('Light'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined),
                    SizedBox(width: 12),
                    Text('Dark'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).signOut();
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not sign out. Please try again.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(context, marketState, selectedMarket),
          const ScreenerScreen(),
          const WatchlistScreen(),
          const PortfolioScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Screener',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_rounded),
            label: 'Portfolio',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    AsyncValue<MarketOverview> marketState,
    String selectedMarket,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live market snapshot',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedMarket == 'IN'
                                ? 'Track NSE & BSE movers in a cleaner, faster view.'
                                : 'Track US equities in a cleaner, faster view.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildHeroChip(
                      context,
                      Icons.public_rounded,
                      'Global view',
                    ),
                    _buildHeroChip(
                      context,
                      Icons.trending_up_rounded,
                      'Fast movers',
                    ),
                    _buildHeroChip(
                      context,
                      Icons.refresh_rounded,
                      'Pull to refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'IN', label: Text('India (NSE/BSE)')),
                  ButtonSegment(value: 'US', label: Text('United States')),
                ],
                selected: {selectedMarket},
                onSelectionChanged: (Set<String> newSelection) {
                  ref.read(selectedMarketProvider.notifier).state =
                      newSelection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: marketState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
              data: (data) => RefreshIndicator(
                onRefresh: () => ref.refresh(marketOverviewProvider.future),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            'Market Indices',
                            'Benchmarks',
                          ),
                          const SizedBox(height: 12),
                          _buildIndexCards(context, data.indices),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            context,
                            'Top Gainers',
                            '${data.topGainers.length} movers',
                          ),
                          const SizedBox(height: 12),
                          _buildStockList(
                            context,
                            data.topGainers,
                            accentColor: Colors.green,
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            context,
                            'Top Losers',
                            '${data.topLosers.length} movers',
                          ),
                          const SizedBox(height: 12),
                          _buildStockList(
                            context,
                            data.topLosers,
                            accentColor: Colors.red,
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            context,
                            'Most Active',
                            'Volume leaders',
                          ),
                          const SizedBox(height: 12),
                          _buildStockList(
                            context,
                            data.mostActive,
                            accentColor: colorScheme.primary,
                            showVolume: true,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexCards(BuildContext context, List<IndexData> indices) {
    if (indices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No index data available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: indices.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = indices[index];
          final isPositive = item.change >= 0;

          return SizedBox(
            width: 176,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.price.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _buildChangeBadge(
                      context,
                      changePercent: item.changePercent,
                      isPositive: isPositive,
                      icon: isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockList(
    BuildContext context,
    List<StockSummary> stocks, {
    required Color accentColor,
    bool showVolume = false,
  }) {
    if (stocks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No stocks available right now.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final isPositive = stock.change >= 0;

        return Card(
          child: ListTile(
            onTap: () => context.push('/stock/${stock.symbol}'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            title: Text(
              stock.symbol,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                stock.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 96),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.price.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildChangeBadge(
                    context,
                    changePercent: stock.changePercent,
                    isPositive: isPositive,
                    icon: isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    compact: true,
                    accentColor: showVolume ? accentColor : null,
                    volume: showVolume ? stock.volume : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      label: Text(label),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.55),
      side: BorderSide.none,
    );
  }

  Widget _buildChangeBadge(
    BuildContext context, {
    required double changePercent,
    required bool isPositive,
    required IconData icon,
    bool compact = false,
    Color? accentColor,
    double? volume,
  }) {
    final backgroundColor = isPositive
        ? const Color(0x1A22C55E)
        : const Color(0x1AF43F5E);
    final foregroundColor = isPositive
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: foregroundColor),
          Text(
            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (volume != null)
            Text(
              '· Vol ${_formatCompactNumber(volume)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color:
                    accentColor ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
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
                const SizedBox(height: 16),
                Text(
                  'Market data is unavailable',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.refresh(marketOverviewProvider.future),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  String _formatCompactNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
