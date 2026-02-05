import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../services/api_service.dart';

class SearchProvider extends ChangeNotifier {
  List<Card> _results = [];
  bool _isLoading = false;
  String? _error;
  Card? _selectedCard;

  List<Card> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Card? get selectedCard => _selectedCard;

  Future<void> searchCards(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await ApiService.searchCards(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> identifyCard(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCard = await ApiService.identifyCard(imagePath);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedCard = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCard(Card card) {
    _selectedCard = card;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCard = null;
    _error = null;
    notifyListeners();
  }
}
