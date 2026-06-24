import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for stocks, companies, indices...'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    // In a real app, this would hit the Riverpod search provider and show loading/results
    // For now, we mock some results based on the query
    final mockResults = [
      {'symbol': 'AAPL', 'name': 'Apple Inc.'},
      {'symbol': 'RELIANCE', 'name': 'Reliance Industries'},
      {'symbol': 'TCS', 'name': 'Tata Consultancy Services'},
    ].where((e) => e['name']!.toLowerCase().contains(query.toLowerCase()) || e['symbol']!.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: mockResults.length,
      itemBuilder: (context, index) {
        final result = mockResults[index];
        return ListTile(
          leading: const Icon(Icons.business),
          title: Text(result['symbol']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(result['name']!),
          onTap: () {
            close(context, null);
            context.push('/stock/${result['symbol']}');
          },
        );
      },
    );
  }
}
