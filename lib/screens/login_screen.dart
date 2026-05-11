import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'cuisine_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleLogin() async {
    // 1. Thêm async ở đây
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ... (phần kiểm tra trống giữ nguyên)

    final provider = Provider.of<AppProvider>(context, listen: false);

    // 2. Thêm await ở đây để biến Future<bool> thành bool
    final success = await provider.login(email, password);

    if (success) {
      // Bây giờ success đã là kiểu bool, không còn lỗi nữa
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CuisineScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sai email hoặc password!')));
    }
  }

  void showTestAccounts() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final users = provider.getAllUsers();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Danh sách tài khoản (Test)"),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? const Text("Chưa có tài khoản nào trong Hive.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text("User: ${user['fullName']}"),
                      subtitle: Text(
                        "Email: ${user['email']}\nPass: ${user['password']}",
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // Tự động điền khi bấm vào tài khoản trong list test
                        emailController.text = user['email'];
                        passwordController.text = user['password'];
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text(
              'Restaurant App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Test@gmail.com',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // NÚT XEM DANH SÁCH TEST
            TextButton.icon(
              onPressed: showTestAccounts,
              icon: const Icon(Icons.bug_report, color: Colors.grey),
              label: const Text(
                "Xem danh sách tài khoản test",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
