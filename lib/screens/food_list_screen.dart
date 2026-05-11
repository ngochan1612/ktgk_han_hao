// lib/screens/food_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_provider.dart';
import 'cart_screen.dart';

class FoodListScreen extends StatelessWidget {
  final Map<String, dynamic> cuisine;
  const FoodListScreen({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final foods = provider.allFoods
        .where((f) => f['cuisineId'] == cuisine['id'])
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        title: const Text('KFC', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (provider.cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${provider.cart.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Nhà hàng giống đề thi
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'KFC',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Block 12', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Danh sách món ăn
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Icon tròn xanh dương
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3F51B5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            food['image'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFC62828),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cuisine['name'].toLowerCase(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            '₹ ${food['price']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          provider.addToCart(food);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thêm ${food['name']}!')),
                          );
                        },
                        child: const Text(
                          'ADD TO CART',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
