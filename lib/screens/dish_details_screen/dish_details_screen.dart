import 'package:flutter/material.dart';

import '../../services/cart_service.dart';

class DishDetailsScreen extends StatefulWidget {
  const DishDetailsScreen({super.key});

  @override
  _DishDetailsScreenState createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends State<DishDetailsScreen> {
  // static data for this example
  final List<String> _days = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'];
  final Set<String> _availableDays = {'Wed', 'Thu', 'Fri', 'Sat'};
  final List<String> _ingredients = [
    'Dough (for the wrappers)',
    'Filling (meat mixture)',
    'Sauce (tomato-yogurt topping)',
    'Yogurt-Garlic Sauce',
  ];
  final List<String> _allergens = ['Dough', 'Dairy', 'Garlic', 'Onion'];
  final List<Map<String, dynamic>> _addOns = [
    {'name': 'Dried mint topping', 'price': 1.00},
  ];
  final Set<int> _selectedAddOns = {};
  bool _isAddingToCart = false;

  double get _basePrice => 12.00;
  double get _totalPrice {
    return _basePrice + _selectedAddOns.length * _addOns.first['price'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F4), // pale pink
      body: Column(
        children: [
          // ────────── top image + appbar row ──────────
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // TODO: swap for your own image asset or network URL
                Image.asset('assets/images/Mantu.jpg', fit: BoxFit.cover),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleIcon(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        _buildCircleIcon(
                          icon: Icons.share,
                          onTap: () {
                            /* share logic */
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ────────── details content ──────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mantuu/Ashaak',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "A traditional favorite served on special occasions and family gatherings, "
                    "Mantuu is more than just food—it's a taste of Afghan hospitality and culture.",
                  ),
                  const SizedBox(height: 24),

                  // Availability chips
                  const Text(
                    'Availability',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _days.map((d) {
                          final isOpen = _availableDays.contains(d);
                          return Chip(
                            label: Text(d),
                            backgroundColor:
                                isOpen ? Colors.green : Colors.grey.shade300,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients & Allergens card
                  _buildWhiteCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredients',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_ingredients.join(', ')),
                        const SizedBox(height: 16),
                        const Text(
                          'Allergens',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_allergens.join(', ')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add-Ons card
                  _buildWhiteCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add-Ons',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Select up to three'),
                        ..._addOns.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final addon = entry.value;
                          final selected = _selectedAddOns.contains(idx);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${addon['name']} (+\$${(addon['price'] as double).toStringAsFixed(2)})',
                            ),
                            value: selected,
                            onChanged: (_) {
                              setState(() {
                                if (selected) {
                                  _selectedAddOns.remove(idx);
                                } else if (_selectedAddOns.length < 3) {
                                  _selectedAddOns.add(idx);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // leave space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ────────── bottom add-to-cart bar ──────────
      bottomSheet: GestureDetector(
        onTap:
            _isAddingToCart
                ? null
                : () async {
                  // Set loading state
                  setState(() {
                    _isAddingToCart = true;
                  });

                  // Show loading indicator
                  final scaffold = ScaffoldMessenger.of(context);
                  try {
                    // Get selected add-ons
                    final selectedAddOnsList =
                        _selectedAddOns.map((index) {
                          final addon = _addOns[index];
                          return {
                            'name': addon['name'] as String,
                            'price': addon['price'] as double,
                          };
                        }).toList();

                    // Add item to cart using CartService
                    await CartService.addDishToCart(
                      dishId: 'mantuu', // Replace with actual dish ID
                      name: 'Mantuu/Ashaak',
                      price: _basePrice,
                      quantity: 1,
                      addOns: selectedAddOnsList,
                    );

                    // Show success message
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart successfully'),
                      ),
                    );

                    // Navigate to cart screen
                    Navigator.pushNamed(context, '/cart');
                  } catch (e) {
                    // Show error message
                    scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    // Reset loading state
                    if (mounted) {
                      setState(() {
                        _isAddingToCart = false;
                      });
                    }
                  }
                },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0E4743), // dark teal
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              _isAddingToCart
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    'Add 1 to Cart',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
              const Spacer(),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon({required IconData icon, VoidCallback? onTap}) {
    return CircleAvatar(
      backgroundColor: Colors.white70,
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildWhiteCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
