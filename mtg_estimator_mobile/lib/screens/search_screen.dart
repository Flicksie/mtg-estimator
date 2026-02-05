import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by card name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().searchCards('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                context.read<SearchProvider>().searchCards(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, _) {
                if (searchProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchProvider.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${searchProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (searchProvider.results.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Enter a card name to search'
                          : 'No cards found',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searchProvider.results.length,
                  itemBuilder: (context, index) {
                    final card = searchProvider.results[index];
                    return ListTile(
                      leading: card.imageUrl.isNotEmpty
                          ? Image.network(
                              card.imageUrl,
                              width: 50,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image),
                            )
                          : const Icon(Icons.image),
                      title: Text(card.name),
                      subtitle: Text('${card.set} • \$${card.price}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardDetailScreen(card: card),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  final dynamic card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.card.imageUrl.isNotEmpty)
                Center(
                  child: Image.network(
                    widget.card.imageUrl,
                    height: 300,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 300),
                  ),
                )
              else
                const Center(
                  child: Icon(Icons.image, size: 300),
                ),
              const SizedBox(height: 24),
              Text(
                widget.card.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.card.set} • ${widget.card.rarity}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.card.price}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<SearchProvider>()
                      .clearSelection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card added to collection!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Add to Collection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
