import 'package:hive/hive.dart';

part 'food_model.g.dart';

@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String cuisineId;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final String image;

  FoodItem({
    required this.id,
    required this.name,
    required this.cuisineId,
    required this.price,
    required this.image,
  });
}
