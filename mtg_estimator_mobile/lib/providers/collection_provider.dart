import 'package:flutter/foundation.dart';
import '../models/collection_item.dart';
import '../models/card.dart';
import '../services/api_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<CollectionItem> _items = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  List<CollectionItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  double get totalValue => _items.fold(0, (sum, item) => sum + item.totalValue);

  Future<void> loadCollection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await ApiService.getCollection();
      await loadStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(Card card, int quantity) async {
    try {
      await ApiService.addToCollection(card, quantity);
      await loadCollection();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeCard(String itemId) async {
    try {
      await ApiService.removeFromCollection(itemId);
      await loadCollection();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await ApiService.getCollectionStats();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
