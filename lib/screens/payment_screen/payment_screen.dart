// lib/screens/payment_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../home/main_navigation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double total;
  final String restaurantName;
  final String deliveryTime;
  final String address;
  final String dropOffNote;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
    required this.restaurantName,
    required this.deliveryTime,
    required this.address,
    required this.dropOffNote,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Preset tip amounts
  final List<double> _tipOptions = [3.0, 5.0, 7.0];
  double? _selectedTip;
  final _customController = TextEditingController();
  bool _isProcessing = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Payment method selection
  String _selectedPaymentMethod = 'Apple Pay';
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Apple Pay', 'icon': Icons.apple, 'color': Colors.black},
    {'name': 'Credit Card', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'name': 'PayPal', 'icon': Icons.paypal, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the first tip option
    _selectedTip = _tipOptions[1]; // 5.0 as default
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectTip(double? tip) {
    setState(() {
      _selectedTip = tip;
      if (tip != null && tip != -1) {
        _customController.clear();
      }
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  // Create order in Firestore
  Future<void> _createOrder() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare order data
      final tipAmount =
          _selectedTip == -1
              ? double.tryParse(_customController.text) ?? 0.0
              : _selectedTip ?? 0.0;

      final grandTotal = widget.total + tipAmount;

      // Convert cart items to order items format
      final orderItems = widget.cartItems.map((item) => item.toMap()).toList();

      // Create order data
      final orderData = {
        'userId': _auth.currentUser!.uid,
        'restaurantId': 'restaurant-123', // Replace with actual restaurant ID
        'restaurantName': widget.restaurantName,
        'items': orderItems,
        'subtotal': widget.subtotal,
        'deliveryFee': widget.deliveryFee,
        'taxes': widget.taxes,
        'tip': tipAmount,
        'total': grandTotal,
        'address': widget.address,
        'dropOffNote': widget.dropOffNote,
        'deliveryTime': widget.deliveryTime,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'processing',
        'orderDate': DateTime.now(),
      };

      // Create order in Firestore
      final orderRef = await OrderService.createOrder(orderData);

      // Clear cart after successful order
      await CartService.clearCart();

      // Show success message and navigate to orders screen
      if (mounted) {
        // Show success animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your order has been placed successfully!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order ID: ${orderRef.id.substring(0, 8)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E4743),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
        );

        // Navigate to main navigation screen with orders tab selected
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(initialIndex: 2),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total with tip
    final tipAmount =
        _selectedTip == -1
            ? double.tryParse(_customController.text) ?? 0.0
            : _selectedTip ?? 0.0;
    final grandTotal = widget.total + tipAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            color: Color(0xFF0E4743),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _isProcessing
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF0E4743)),
                    const SizedBox(height: 24),
                    const Text(
                      'Processing your order...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait a moment',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0E4743,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF0E4743),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.restaurantName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Delivery: ${widget.deliveryTime}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${widget.cartItems.length} items',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tip section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & subtitle
                              Row(
                                children: [
                                  const Icon(
                                    Icons.volunteer_activism,
                                    color: Color(0xFF0E4743),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Add Tip',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedTip != null)
                                    Text(
                                      '\$${_selectedTip == -1 ? (_customController.text.isEmpty ? '0.00' : _customController.text) : _selectedTip!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E4743),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Share the love by splitting the tip evenly between the chef and delivery driver',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tip options
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Preset amounts
                                  for (var amt in _tipOptions)
                                    _buildTipButton(
                                      label: '\$${amt.toStringAsFixed(0)}',
                                      isSelected: _selectedTip == amt,
                                      onTap: () => _selectTip(amt),
                                    ),

                                  // Custom
                                  _selectedTip == -1
                                      ? SizedBox(
                                        width: 80,
                                        height: 45,
                                        child: TextField(
                                          controller: _customController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText: 'Custom',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            prefixIcon: const Icon(
                                              Icons.attach_money,
                                              size: 16,
                                            ),
                                          ),
                                          onChanged: (val) {
                                            setState(() {});
                                          },
                                        ),
                                      )
                                      : _buildTipButton(
                                        label: 'Custom',
                                        isSelected: false,
                                        onTap: () => _selectTip(-1),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Payment methods
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.payment,
                                    color: Color(0xFF0E4743),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Payment method options
                              ...List.generate(
                                _paymentMethods.length,
                                (index) => _buildPaymentMethodOption(
                                  name: _paymentMethods[index]['name'],
                                  icon: _paymentMethods[index]['icon'],
                                  color: _paymentMethods[index]['color'],
                                  isSelected:
                                      _selectedPaymentMethod ==
                                      _paymentMethods[index]['name'],
                                  onTap:
                                      () => _selectPaymentMethod(
                                        _paymentMethods[index]['name'],
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Order summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    color: Color(0xFF0E4743),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow('Subtotal', widget.subtotal),
                              _buildSummaryRow(
                                'Delivery Fee',
                                widget.deliveryFee,
                              ),
                              _buildSummaryRow('Taxes', widget.taxes),
                              _buildSummaryRow('Tip', tipAmount),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(),
                              ),
                              _buildSummaryRow(
                                'Total',
                                grandTotal,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Place Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _createOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E4743),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_getPaymentIcon(), color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Complete Order - \$${grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and conditions
                        Center(
                          child: Text(
                            'By clicking "Complete Order", you agree to the Terms and Conditions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  IconData _getPaymentIcon() {
    switch (_selectedPaymentMethod) {
      case 'Apple Pay':
        return Icons.apple;
      case 'Credit Card':
        return Icons.credit_card;
      case 'PayPal':
        return Icons.paypal;
      default:
        return Icons.payment;
    }
  }

  Widget _buildPaymentMethodOption({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF0E4743).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4743) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0E4743)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E4743) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4743) : Colors.grey[300]!,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF0E4743).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF0E4743) : null,
            ),
          ),
        ],
      ),
    );
  }
}
