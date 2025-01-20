import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _phoneNumber;
  String? _email;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;

  void setUser(String userId, String phoneNumber , String email) {
    _userId = userId;
    _phoneNumber = phoneNumber;
    _email = email;
    notifyListeners(); // Notify listeners when data is updated
  }
}
