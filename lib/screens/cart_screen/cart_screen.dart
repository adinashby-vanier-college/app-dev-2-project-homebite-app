// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy cart data
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Qabili Palaw',
      'quantity': 1,
      'price': 12.00,
      'addons': [
        {'title': 'Extra Bread with sauce', 'quantity': 1, 'price': 1.00},
        {'title': 'Extra Bread with sauce', 'quantity': 1, 'price': 1.00},
      ],
    },
    {
      'name': 'Qabili Palaw',
      'quantity': 1,
      'price': 12.00,
      'addons': [
        {'title': 'Extra Bread with sauce', 'quantity': 1, 'price': 1.00},
        {'title': 'Extra Bread with sauce', 'quantity': 1, 'price': 1.00},
      ],
    },
  ];

  final String _restaurant = "l’Afghan Maison";
  final String _deliveryDay = 'Wed Apr 16';
  final String _deliveryTime = '3:00PM - 3:30PM';

  double get _subtotal {
    var total = 0.0;
    for (var item in _cartItems) {
      total += item['price'] as double;
      for (var a in item['addons'] as List) {
        total += a['price'] as double;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add more items',
          style: TextStyle(color: Color(0xFF0066CC), fontSize: 20),
        ),
        titleSpacing: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _cartItems.clear());
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _restaurant,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Cart items list
            Expanded(
              child: ListView.separated(
                itemCount: _cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _buildCartItem(_cartItems[i]),
              ),
            ),

            const SizedBox(height: 12),
            // “Add more items” button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E4743),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Add more items'),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery & Subtotal card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Delivery row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Delivered'),
                            Text('$_deliveryDay, $_deliveryTime'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: change delivery slot
                        },
                        child: const Text('Change', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Subtotal row
                  Row(
                    children: [
                      const Text('Subtotal'),
                      const Spacer(),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // leave room for bottomSheet
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF0E4743),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: TextButton(
          onPressed: () {
            // TODO: proceed to checkout
          },
          child: Text(
            'Checkout (${_cartItems.length})',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity circle
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.amber,
            child: Text(item['quantity'].toString(), style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          // Item name + addons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...List<Widget>.from(
                  (item['addons'] as List).map((a) {
                    return Text(
                      "${a['quantity']}× ${a['title']}    \$${(a['price'] as double).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 12),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Price + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${(item['price'] as double).toStringAsFixed(2)}'),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() => _cartItems.remove(item));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
