class Card {
  final String id;
  final String name;
  final String set;
  final String rarity;
  final double price;
  final String imageUrl;

  Card({
    required this.id,
    required this.name,
    required this.set,
    required this.rarity,
    required this.price,
    required this.imageUrl,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      set: json['set'] ?? '',
      rarity: json['rarity'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'set': set,
    'rarity': rarity,
    'price': price,
    'image_url': imageUrl,
  };
}
