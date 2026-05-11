import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_model.dart';
import '../data/local_data.dart';

class HiveService {
  static const String foodBoxName = 'foodBox';
  static const String userBoxName = 'userBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodItemAdapter());

    // ❌ ĐÃ XÓA: deleteBoxFromDisk — tránh mất data mỗi lần khởi động app
    // await Hive.deleteBoxFromDisk(foodBoxName);
    // await Hive.deleteBoxFromDisk(userBoxName);

    await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox(userBoxName);

    // Seed dữ liệu ban đầu nếu box còn trống
    await seedData();
  }

  static Future<void> seedData() async {
    final foodBox = Hive.box<FoodItem>(foodBoxName);
    final userBox = Hive.box(userBoxName);

    // Chỉ nạp nếu box đang trống — tránh ghi đè dữ liệu hiện có
    if (foodBox.isEmpty) {
      final initialFoods = foods.map((item) {
        return FoodItem(
          id: item['id'].toString(),
          name: item['name'].toString(),
          cuisineId: item['cuisineId'].toString(),
          price: (item['price'] as num).toDouble(),
          image: item['image'].toString(),
        );
      }).toList();

      await foodBox.addAll(initialFoods);
      print("✅ Đã nạp ${initialFoods.length} món ăn vào Hive!");
    }

    // Nạp tài khoản test mặc định (chỉ cho Hive, không tạo Firebase Auth)
    if (userBox.isEmpty) {
      for (var user in users) {
        await userBox.put(user['email'], user);
      }
      print("✅ Đã nạp ${users.length} tài khoản test vào Hive!");
    }
  }
}
