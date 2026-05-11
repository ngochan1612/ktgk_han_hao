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

  // FIX: Thêm async để xử lý đợi Firebase
  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);

    // FIX: Thêm await để lấy giá trị bool thật sự từ Future
    final success = await provider.login(email, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CuisineScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sai email hoặc password!')));
    }
  }

  // Các hàm showTestAccounts và build giữ nguyên logic nhưng đảm bảo dùng handleLogin mới
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
                hintText: 'Email',
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
            const SizedBox(height: 16),
            // Nút Đồng bộ Menu (Sync)
            TextButton.icon(
              onPressed: () async {
                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                await provider.syncAllDataToFirebase();
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đồng bộ lên Firebase!')),
                  );
              },
              icon: const Icon(Icons.cloud_upload, color: Colors.blue),
              label: const Text("Đồng bộ Menu lên Cloud"),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );
                final users = provider.getAllUsers();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Danh sách User (Test)'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (_, i) => ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(users[i]['email'] ?? ''),
                          subtitle: Text(users[i]['fullName'] ?? ''),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('🧪 Xem danh sách User (Test)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
