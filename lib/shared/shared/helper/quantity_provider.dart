import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  final Map<String, double> _quantities = {};

  double getQuantity(String productId) {
    return _quantities[productId] ?? 1.0;
  }

  void increaseQuantity(String productId) {
    _quantities[productId] = getQuantity(productId) + 1.0;
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (getQuantity(productId) > 1.0) {
      _quantities[productId] = getQuantity(productId) - 1.0;
      notifyListeners();
    }
  }
}
