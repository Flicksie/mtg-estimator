import 'card.dart';

class CollectionItem {
  final String id;
  final Card card;
  final int quantity;
  final DateTime addedAt;

  CollectionItem({
    required this.id,
    required this.card,
    required this.quantity,
    required this.addedAt,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] ?? '',
      card: Card.fromJson(json['card'] ?? {}),
      quantity: json['quantity'] ?? 1,
      addedAt: DateTime.parse(json['added_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'card': card.toJson(),
    'quantity': quantity,
    'added_at': addedAt.toIso8601String(),
  };

  double get totalValue => card.price * quantity;
}
