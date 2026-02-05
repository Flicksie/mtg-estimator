import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/card.dart';
import '../models/collection_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5004/api'; // Adjust to your backend URL

  // Card Search
  static Future<List<Card>> searchCards(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> cards = jsonData['cards'] ?? [];
        return cards.map((card) => Card.fromJson(card)).toList();
      }
      throw Exception('Failed to search cards: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error searching cards: $e');
    }
  }

  // Card Identification (from image)
  static Future<Card> identifyCard(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/identify'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        return Card.fromJson(jsonData['card'] ?? {});
      }
      throw Exception('Failed to identify card: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error identifying card: $e');
    }
  }

  // Collection Management
  static Future<List<CollectionItem>> getCollection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collection/list'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> items = jsonData['items'] ?? [];
        return items.map((item) => CollectionItem.fromJson(item)).toList();
      }
      throw Exception('Failed to get collection: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting collection: $e');
    }
  }

  static Future<void> addToCollection(Card card, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/collection/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'card_id': card.id,
          'quantity': quantity,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to add to collection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to collection: $e');
    }
  }

  static Future<void> removeFromCollection(String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/collection/remove'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'item_id': itemId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from collection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing from collection: $e');
    }
  }

  static Future<Map<String, dynamic>> getCollectionStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get stats: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }
}
