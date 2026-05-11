// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_provider.dart';
import 'payment_success_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFFC62828),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.cart.isEmpty
          ? const Center(child: Text('Giỏ hàng trống!'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.cart.length,
                    itemBuilder: (context, index) {
                      final item = provider.cart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Color(0xFFC62828),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (item['quantity'] == 1) {
                                        // Hiện Dialog xác nhận xóa khi số lượng lùi về 0
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Xóa món ăn',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            content: Text(
                                              'Bạn có chắc muốn xóa ${item['name']} khỏi giỏ hàng?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  ctx,
                                                ), // Tắt Dialog
                                                child: const Text(
                                                  'Hủy',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green.shade700,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.zero,
                                                      ),
                                                ),
                                                onPressed: () async {
                                                  // Thêm async
                                                  final total =
                                                      provider.totalPay;

                                                  // UI CHỈ CẦN GỌI PROVIDER, KHÔNG CẦN QUAN TÂM FIREBASE HAY HIVE
                                                  bool success = await provider
                                                      .checkoutAndSyncToFirebase();

                                                  if (success) {
                                                    // Chuyển sang màn hình thành công
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            PaymentSuccessScreen(
                                                              total: total,
                                                            ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Báo lỗi nếu rớt mạng hoặc chưa đăng nhập
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Thanh toán thất bại, vui lòng thử lại!',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  'Proceed To Pay',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // Nếu số lượng > 1 thì cứ trừ bình thường
                                        provider.updateQuantity(item['id'], -1);
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        provider.updateQuantity(item['id'], 1),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '+',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '₹${item['price']}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Phần Hóa đơn Bill Receipt
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Receipt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRow('Items Total', '${provider.itemsTotal} ₹'),
                      _buildRow('Offer Discount', '-18 ₹'),
                      _buildRow(
                        'Taxes (8%)',
                        '${(provider.itemsTotal * 0.08).toStringAsFixed(2)} ₹',
                      ),
                      _buildRow('Delivery Charges', '30 ₹'),
                      const Divider(),
                      _buildRow(
                        'Total Pay',
                        '${provider.totalPay.toStringAsFixed(2)} ₹',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: provider.cart.isEmpty
          ? null
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: Text(
                        '₹ ${provider.totalPay.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          final total = provider.totalPay;
                          provider.clearCart();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentSuccessScreen(total: total),
                            ),
                          );
                        },
                        child: const Text(
                          'Proceed To Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
