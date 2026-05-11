import 'package:flutter/material.dart';
import '../data/local_data.dart';

class AppProvider extends ChangeNotifier {
  // User login state
  Map<String, dynamic>? userLogin;

  // Cart
  List<Map<String, dynamic>> cart = [];

  // All data
  List<Map<String, dynamic>> allFoods = List.from(foods);
  List<Map<String, dynamic>> allCuisines = List.from(cuisines);
  List<Map<String, dynamic>> allUsers = List.from(users);

  // LOGIN
  bool login(String email, String password) {
    final user = allUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      userLogin = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  // LOGOUT
  void logout() {
    userLogin = null;
    cart = [];
    notifyListeners();
  }

  // REGISTER
  bool register(String email, String password, String fullName) {
    final exists = allUsers.any((u) => u['email'] == email);
    if (exists) return false;
    allUsers.add({"email": email, "password": password, "fullName": fullName});
    notifyListeners();
    return true;
  }

  // FORGOT PASSWORD
  bool resetPassword(String email, String newPassword) {
    final index = allUsers.indexWhere((u) => u['email'] == email);
    if (index == -1) return false;
    allUsers[index]['password'] = newPassword;
    notifyListeners();
    return true;
  }

  // ADD TO CART
  void addToCart(Map<String, dynamic> food) {
    final index = cart.indexWhere((item) => item['id'] == food['id']);
    if (index >= 0) {
      cart[index]['quantity'] += 1;
    } else {
      cart.add({...food, 'quantity': 1});
    }
    notifyListeners();
  }

  // UPDATE QUANTITY
  void updateQuantity(String id, int change) {
    final index = cart.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      cart[index]['quantity'] += change;
      if (cart[index]['quantity'] <= 0) {
        cart.removeAt(index);
      }
    }
    notifyListeners();
  }

  // CLEAR CART
  void clearCart() {
    cart = [];
    notifyListeners();
  }

  // TOTAL
  int get itemsTotal => cart.fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));
  double get discount => itemsTotal * 0.017;
  double get tax => itemsTotal * 0.08;
  double get deliveryCharge => 30;
  double get totalPay => itemsTotal - discount + tax + deliveryCharge;

  // CART COUNT
  int get cartCount => cart.fold(0, (sum, item) => sum + (item['quantity'] as int));
}