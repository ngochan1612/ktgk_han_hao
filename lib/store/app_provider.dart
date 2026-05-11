import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../models/food_model.dart';
import '../data/local_data.dart';

class AppProvider extends ChangeNotifier {
  Map<String, dynamic>? userLogin;
  List<Map<String, dynamic>> cart = [];

  // --- 1. LẤY DỮ LIỆU TỪ HIVE ---

  // Lấy danh sách món ăn từ Hive Box và convert sang Map
  List<Map<String, dynamic>> get allFoods {
    final box = Hive.box<FoodItem>(HiveService.foodBoxName);
    return box.values
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'cuisineId': item.cuisineId,
            'price': item.price,
            'image': item.image,
          },
        )
        .toList();
  }

  // Lấy danh sách danh mục (Cuisines) - lấy từ local_data hoặc Hive tùy bạn setup
  List<Map<String, dynamic>> allCuisines = List.from(cuisines);

  // Lấy danh sách User từ Hive Box
  List<Map<String, dynamic>> getAllUsers() {
    final box = Hive.box(HiveService.userBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // --- 2. LOGIC AUTHENTICATION (XỬ LÝ TRÊN HIVE) ---

  bool login(String email, String password) {
    final users = getAllUsers();
    final user = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => <String, dynamic>{},
    );
    if (user.isNotEmpty) {
      userLogin = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    userLogin = null;
    cart = [];
    notifyListeners();
  }

  bool register(String email, String password, String fullName) {
    final box = Hive.box(HiveService.userBoxName);
    if (box.containsKey(email)) return false;

    final newUser = {
      "email": email,
      "password": password,
      "fullName": fullName,
    };
    box.put(email, newUser); // Lưu vào Hive
    notifyListeners();
    return true;
  }

  bool resetPassword(String email, String newPassword) {
    final box = Hive.box(HiveService.userBoxName);
    if (!box.containsKey(email)) return false;

    var user = Map<String, dynamic>.from(box.get(email));
    user['password'] = newPassword;
    box.put(email, user);
    notifyListeners();
    return true;
  }

  // --- 3. LOGIC GIỎ HÀNG ---

  void addToCart(Map<String, dynamic> food) {
    final index = cart.indexWhere((item) => item['id'] == food['id']);
    if (index >= 0) {
      cart[index]['quantity'] += 1;
    } else {
      cart.add({...food, 'quantity': 1});
    }
    notifyListeners();
  }

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

  void clearCart() {
    cart = [];
    notifyListeners();
  }

  int get cartCount =>
      cart.fold(0, (sum, item) => sum + (item['quantity'] as int));
  int get itemsTotal => cart.fold(
    0,
    (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
  );
  double get totalPay => itemsTotal - 18 + (itemsTotal * 0.08) + 30;

  // --- 4. LOGIC FIREBASE (ĐỒNG BỘ TỪ HIVE LÊN CLOUD) ---

  // Đẩy hóa đơn mới lên Firebase khi thanh toán
  Future<bool> checkoutAndSyncToFirebase() async {
    try {
      if (userLogin == null || cart.isEmpty) return false;

      await FirebaseFirestore.instance.collection("ORDERS").add({
        "userEmail": userLogin!['email'],
        "items": List.from(cart),
        "totalPay": totalPay,
        "status": "Success",
        "createdAt": FieldValue.serverTimestamp(),
      });

      clearCart();
      return true;
    } catch (e) {
      debugPrint("Lỗi sync Order: $e");
      return false;
    }
  }

  // Hàm "Bơm" toàn bộ dữ liệu từ Hive lên Cloud (Chạy 1 lần duy nhất)
  Future<void> syncAllDataToFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Lấy Foods từ Hive -> Firestore
      for (var food in allFoods) {
        await firestore.collection("FOODS").doc(food['id']).set(food);
      }

      // 2. Lấy Users từ Hive -> Firestore
      final currentUsers = getAllUsers();
      for (var user in currentUsers) {
        await firestore.collection("USERS").doc(user['email']).set({
          "email": user['email'],
          "password": user['password'],
          "fullName": user['fullName'] ?? "Khách hàng",
        });
      }

      // 3. Cuisines (Dữ liệu danh mục)
      for (var cuisine in allCuisines) {
        await firestore.collection("CUISINES").doc(cuisine['id']).set(cuisine);
      }

      debugPrint("✅ Đã đồng bộ toàn bộ dữ liệu TỪ HIVE lên Firebase!");
    } catch (e) {
      debugPrint("❌ Lỗi đồng bộ: $e");
    }
  }
}
