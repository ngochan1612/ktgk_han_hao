import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_model.dart';
import '../data/local_data.dart'; // Đảm bảo đường dẫn này đúng với file local_data của bạn

class HiveService {
  static const String foodBoxName = 'foodBox';
  static const String userBoxName = 'userBox'; // Box chứa danh sách tài khoản

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodItemAdapter());

    // 1. PHẢI XÓA SẠCH DỮ LIỆU CŨ BỊ LỖI TRƯỚC TIÊN
    await Hive.deleteBoxFromDisk(foodBoxName);
    await Hive.deleteBoxFromDisk(userBoxName);

    // 2. SAU ĐÓ MỚI MỞ BOX MỚI TINH LÊN
    await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox(userBoxName);

    // 3. NẠP DỮ LIỆU TỪ FILE LOCAL_DATA
    await seedData();
  }

  static Future<void> seedData() async {
    var foodBox = Hive.box<FoodItem>(foodBoxName);
    var userBox = Hive.box(userBoxName);

    // Nạp món ăn
    if (foodBox.isEmpty) {
      List<FoodItem> initialFoods = foods.map((item) {
        return FoodItem(
          id: item['id'].toString(),
          name: item['name'].toString(),
          cuisineId: item['cuisineId'].toString(),
          price: (item['price'] as num).toDouble(),
          image: item['image'].toString(),
        );
      }).toList();

      await foodBox.addAll(initialFoods);
      print("Đã nạp ${initialFoods.length} món ăn vào Hive Database!");
    }

    // Nạp tài khoản test
    if (userBox.isEmpty) {
      for (var user in users) {
        await userBox.put(user['email'], user);
      }
      print("Đã nạp danh sách tài khoản test vào Hive Database!");
    }
  }
}
