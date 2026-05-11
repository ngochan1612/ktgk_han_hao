import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../models/food_model.dart';
import '../data/local_data.dart';

class AppProvider extends ChangeNotifier {
  Map<String, dynamic>? userLogin;
  List<Map<String, dynamic>> cart = [];

  // --- 1. GETTERS LẤY DỮ LIỆU ---

  // Lấy danh sách món ăn trực tiếp từ Hive
  List<Map<String, dynamic>> get allFoods {
    final box = Hive.box<FoodItem>(HiveService.foodBoxName);
    return box.values
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'cuisineId': item.cuisineId,
            'price': item.price, // double
            'image': item.image,
          },
        )
        .toList();
  }

  // Lấy danh sách danh mục
  List<Map<String, dynamic>> allCuisines = List.from(cuisines);

  // Lấy danh sách tài khoản từ Hive
  List<Map<String, dynamic>> getAllUsers() {
    final box = Hive.box(HiveService.userBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // --- 2. LOGIC AUTHENTICATION (FIREBASE AUTH + HIVE DỰ PHÒNG) ---

  // ĐĂNG NHẬP
  Future<bool> login(String email, String password) async {
    try {
      // Xác thực với Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin chi tiết từ Firestore
      final doc = await FirebaseFirestore.instance
          .collection("USERS")
          .doc(email)
          .get();

      if (doc.exists) {
        userLogin = doc.data() as Map<String, dynamic>;
      } else {
        // Dự phòng: lấy từ Hive nếu Firestore chưa có
        final box = Hive.box(HiveService.userBoxName);
        if (box.containsKey(email)) {
          userLogin = Map<String, dynamic>.from(box.get(email));
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi Login: $e");
      return false;
    }
  }

  // ĐĂNG KÝ
  Future<bool> register(String email, String password, String fullName) async {
    try {
      // 1. Tạo tài khoản trên Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userData = {
        "email": email,
        "fullName": fullName,
        "uid": userCredential.user?.uid ?? "",
      };

      // 2. Lưu thông tin vào Firestore (KHÔNG lưu password)
      await FirebaseFirestore.instance
          .collection("USERS")
          .doc(email)
          .set(userData);

      // 3. Lưu vào Hive để dùng offline
      final box = Hive.box(HiveService.userBoxName);
      await box.put(email, userData);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi Register: $e");
      return false;
    }
  }

  // QUÊN MẬT KHẨU — Firebase tự gửi email reset, không cần nhập password mới
  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint("✅ Đã gửi email reset password tới $email");
      return true;
    } catch (e) {
      debugPrint("❌ Lỗi Reset Password: $e");
      return false;
    }
  }

  // ĐĂNG XUẤT
  void logout() {
    FirebaseAuth.instance.signOut();
    userLogin = null;
    cart = [];
    notifyListeners();
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
      if (cart[index]['quantity'] <= 0) cart.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    cart = [];
    notifyListeners();
  }

  int get cartCount =>
      cart.fold(0, (sum, item) => sum + (item['quantity'] as int));

  // Sửa: price là double nên dùng (num).toDouble() thay vì cast sang int
  double get itemsTotal => cart.fold(
    0.0,
    (sum, item) =>
        sum + (item['price'] as num).toDouble() * (item['quantity'] as int),
  );

  double get totalPay => itemsTotal - 18 + (itemsTotal * 0.08) + 30;

  // --- 4. ĐỒNG BỘ DỮ LIỆU LÊN FIREBASE ---

  // Đẩy đơn hàng lên Firebase khi thanh toán
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
      debugPrint("❌ Lỗi Checkout: $e");
      return false;
    }
  }

  // Đẩy dữ liệu tĩnh (Foods, Cuisines) từ Hive lên Firebase — chỉ chạy 1 lần
  Future<void> syncAllDataToFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Sync Foods
      for (var food in allFoods) {
        await firestore.collection("FOODS").doc(food['id']).set(food);
      }

      // 2. Sync Cuisines
      for (var cuisine in allCuisines) {
        await firestore.collection("CUISINES").doc(cuisine['id']).set(cuisine);
      }

      debugPrint("✅ Đã đồng bộ Foods & Cuisines lên Firebase thành công!");
    } catch (e) {
      debugPrint("❌ Lỗi Sync: $e");
    }
  }
}
