// lib/screens/cuisine_screen.dart
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_provider.dart';
import 'food_list_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class CuisineScreen extends StatelessWidget {
  const CuisineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.userLogin;

    void goToLogin() {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Restaurant App',
          style: TextStyle(
            color: Color(0xFFC62828),
            fontWeight: FontWeight.bold,
          ),
        ),
        // Nút mở Drawer (Hamburger menu)
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
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
      // THÊM DRAWER THEO YÊU CẦU CỦA ĐỀ THI
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFC62828)),
              accountName: Text(user?['fullName'] ?? 'Khách hàng'),
              accountEmail: Text(user?['email'] ?? 'Chưa đăng nhập'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                provider.logout();
                goToLogin();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào! ${user?['fullName'] ?? 'Khách hàng'}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.allCuisines.length,
                itemBuilder: (context, index) {
                  final cuisine = provider.allCuisines[index];
                  return Card(
                    color: Colors.white,
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(
                        cuisine['image'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        cuisine['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodListScreen(cuisine: cuisine),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
