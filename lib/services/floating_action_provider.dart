import 'package:flutter/material.dart';

class ButtonPositionProvider with ChangeNotifier {
  Offset _buttonPosition = const Offset(300, 650);

  Offset get buttonPosition => _buttonPosition;

  void updatePosition(Offset newPosition) {
    _buttonPosition = newPosition;
    notifyListeners();
  }
}
