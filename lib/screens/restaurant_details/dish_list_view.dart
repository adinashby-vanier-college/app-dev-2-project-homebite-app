import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../screens/home/main_navigation_screen.dart';
import '../../services/cart_service.dart';

class DishList extends StatelessWidget {
  final List<Map<String, dynamic>> dishes;

  const DishList({super.key, required this.dishes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return InkWell(
          onTap: () {
            _showDishDetails(context, dish, index);
          },
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: _buildDishImage(dish),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dish['rating'] ?? '0.0'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Dish Details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dish['name'] ?? 'Unnamed Dish',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatPrice(dish['price']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        dish['description'] ?? 'No description available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Available Add-ons preview
                      if (dish['addOns'] != null &&
                          (dish['addOns'] as List).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 14,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(dish['addOns'] as List).length} add-ons available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Add to Cart button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [_AddToCartButton(dish: dish, index: index)],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDishDetails(
    BuildContext context,
    Map<String, dynamic> dish,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DishDetailsSheet(dish: dish, index: index),
    );
  }

  Widget _buildDishImage(Map<String, dynamic> dish) {
    final imageUrl = dish['imageUrl'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
      );
    } else {
      return Image.asset(dish['image'] ?? 'assets/images/kebab.png');
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0.00';

    if (price is num) {
      return '\$${price.toStringAsFixed(2)}';
    }

    if (price is String) {
      if (price.startsWith('\$')) return price;

      final numPrice = double.tryParse(price);
      if (numPrice != null) {
        return '\$${numPrice.toStringAsFixed(2)}';
      }
    }

    return '\$0.00';
  }
}

class DishDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> dish;
  final int index;

  const DishDetailsSheet({super.key, required this.dish, required this.index});

  @override
  State<DishDetailsSheet> createState() => _DishDetailsSheetState();
}

class _DishDetailsSheetState extends State<DishDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: _buildDishImage(),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.dish['name'] ?? 'Unnamed Dish',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              _formatPrice(widget.dish['price']),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),

                        // Rating
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.dish['rating'] ?? '0.0'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.dish['reviews'] ?? '0'} reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.dish['description'] ??
                              'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),

                        // Ingredients if available
                        if (widget.dish['ingredients'] != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildIngredientsList(widget.dish['ingredients']),
                        ],

                        // Add-ons
                        const SizedBox(height: 24),
                        const Text(
                          'Available Add-ons',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAddOns(),

                        // Nutritional info if available
                        if (widget.dish['nutritionalInfo'] != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Nutritional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNutritionalInfo(widget.dish['nutritionalInfo']),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to cart button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _AddToCartButton(
              dish: widget.dish,
              index: widget.index,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishImage() {
    final imageUrl = widget.dish['imageUrl'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
      );
    } else {
      return Image.asset(widget.dish['image'] ?? 'assets/images/kebab.png');
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0.00';

    if (price is num) {
      return '\$${price.toStringAsFixed(2)}';
    }

    if (price is String) {
      if (price.startsWith('\$')) return price;

      final numPrice = double.tryParse(price);
      if (numPrice != null) {
        return '\$${numPrice.toStringAsFixed(2)}';
      }
    }

    return '\$0.00';
  }

  Widget _buildIngredientsList(dynamic ingredients) {
    if (ingredients is! List || ingredients.isEmpty) {
      return const Text('No ingredients information available');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          ingredients.map<Widget>((ingredient) {
            return Chip(
              label: Text(
                ingredient.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.grey.shade100,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
    );
  }

  Widget _buildAddOns() {
    final addOns = widget.dish['addOns'] as List?;

    if (addOns == null || addOns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No add-ons available for this dish'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addOns.length,
      itemBuilder: (context, index) {
        final addon = addOns[index];
        final name = addon['name'] as String? ?? 'Add-on';
        final price = addon['price'];

        String formattedPrice = '';
        if (price is num) {
          formattedPrice = '+\$${price.toStringAsFixed(2)}';
        } else if (price is String) {
          final numPrice = double.tryParse(price.replaceAll('\$', ''));
          if (numPrice != null) {
            formattedPrice = '+\$${numPrice.toStringAsFixed(2)}';
          } else {
            formattedPrice = '+$price';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Colors.teal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (addon['description'] != null)
                      Text(
                        addon['description'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionalInfo(dynamic nutritionalInfo) {
    if (nutritionalInfo is! Map) {
      return const Text('No nutritional information available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children:
            nutritionalInfo.entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  final Map<String, dynamic> dish;
  final int index;
  final bool isExpanded;

  const _AddToCartButton({
    required this.dish,
    required this.index,
    this.isExpanded = false,
  });

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _isLoading = false;
  bool _showAddOns = false;
  bool _isInCart = false;
  final Set<int> _selectedAddOns = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
  }

  Future<void> _checkIfInCart() async {
    try {
      final isInCart = await CartService.isDishInCart(
        widget.dish['id']?.toString() ?? 'dish_${widget.index}',
      );
      if (mounted) {
        setState(() {
          _isInCart = isInCart;
        });
      }
    } catch (e) {
      debugPrint('Error checking if dish is in cart: $e');
    }
  }

  List<Map<String, dynamic>> get _availableAddOns {
    if (widget.dish['addOns'] == null) return [];

    try {
      return (widget.dish['addOns'] as List?)?.map<Map<String, dynamic>>((
            addon,
          ) {
            if (addon is Map) {
              return {
                'name': addon['name']?.toString() ?? 'Add-on',
                'price': _parsePrice(addon['price']),
              };
            }
            return {'name': 'Add-on', 'price': 0.0};
          }).toList() ??
          [];
    } catch (e) {
      debugPrint('Error processing addOns: $e');
      return [];
    }
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll('\$', '')) ?? 0.0;
    }
    return 0.0;
  }

  void _addToCart() async {
    // If already in cart, go to cart
    if (_isInCart) {
      _goToCart();
      return;
    }

    // If in detail view and has add-ons, show add-ons selection
    if (widget.isExpanded && _availableAddOns.isNotEmpty && !_showAddOns) {
      setState(() {
        _showAddOns = true;
      });
      return;
    }

    // If in list view and has add-ons, show dish details
    if (!widget.isExpanded && _availableAddOns.isNotEmpty && !_showAddOns) {
      // Find the nearest scaffold to show the bottom sheet
      final context = this.context;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) =>
                DishDetailsSheet(dish: widget.dish, index: widget.index),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    // Show loading indicator
    final scaffold = ScaffoldMessenger.of(context);
    try {
      // Get selected add-ons
      final selectedAddOnsList =
          _selectedAddOns.map((index) {
            final addon = _availableAddOns[index];
            return {
              'name': addon['name'] as String,
              'price': addon['price'] as double,
            };
          }).toList();

      // Add to cart functionality
      await CartService.addDishToCart(
        dishId: widget.dish['id']?.toString() ?? 'dish_${widget.index}',
        name: widget.dish['name']?.toString() ?? 'Unnamed Dish',
        price: _parsePrice(widget.dish['price']),
        quantity: _quantity,
        addOns: selectedAddOnsList,
      );

      // Show success message
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Added to cart successfully'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset add-ons view and update cart status
      if (mounted) {
        setState(() {
          _showAddOns = false;
          _selectedAddOns.clear();
          _quantity = 1;
          _isInCart = true;
        });
      }

      // If in detail view, close the bottom sheet
      if (widget.isExpanded) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      scaffold.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // Reset loading state if component is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeFromCart() async {
    setState(() {
      _isLoading = true;
    });

    final scaffold = ScaffoldMessenger.of(context);
    try {
      await CartService.removeFromCart(
        dishId: widget.dish['id']?.toString() ?? 'dish_${widget.index}',
      );

      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Removed from cart'),
          backgroundColor: Colors.grey,
        ),
      );

      if (mounted) {
        setState(() {
          _isInCart = false;
        });
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToCart() {
    // Navigate to cart screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialIndex: 3),
      ),
    );
  }

  double _calculateTotalPrice() {
    double basePrice = _parsePrice(widget.dish['price']) * _quantity;
    double addOnsPrice = 0;

    for (var index in _selectedAddOns) {
      addOnsPrice += _availableAddOns[index]['price'] as double;
    }

    return basePrice + (addOnsPrice * _quantity);
  }

  @override
  Widget build(BuildContext context) {
    // If already in cart and in list view, show remove/view cart buttons
    if (_isInCart && !widget.isExpanded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _isLoading ? null : _removeFromCart,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                    : const Icon(Icons.remove_shopping_cart, color: Colors.red),
            tooltip: 'Remove from cart',
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: _goToCart,
            icon: const Icon(
              Icons.shopping_cart_checkout,
              size: 16,
              color: Colors.white,
            ),
            label: const Text(
              'View Cart',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      );
    }

    // If already in cart and in detail view, show view cart button
    if (_isInCart && widget.isExpanded) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _removeFromCart,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                      : const Icon(
                        Icons.remove_shopping_cart,
                        color: Colors.red,
                      ),
              label: const Text(
                'Remove from Cart',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _goToCart,
              icon: const Icon(Icons.shopping_cart_checkout, size: 16),
              label: const Text(
                'View Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // If in details view and showing add-ons selection
    if (widget.isExpanded && _showAddOns) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Customize Your Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Quantity selector
          Row(
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed:
                          _quantity > 1
                              ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                              : null,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add-ons selection
          if (_availableAddOns.isNotEmpty) ...[
            const Text(
              'Select Add-ons:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ..._availableAddOns.asMap().entries.map((entry) {
              final idx = entry.key;
              final addon = entry.value;
              final selected = _selectedAddOns.contains(idx);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.teal.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        selected ? Colors.teal.shade200 : Colors.grey.shade200,
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  title: Text(
                    addon['name'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    '+\$${(addon['price'] as double).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  secondary:
                      selected
                          ? const Icon(Icons.check_circle, color: Colors.teal)
                          : const Icon(Icons.add_circle_outline),
                  value: selected,
                  onChanged: (_) {
                    setState(() {
                      if (selected) {
                        _selectedAddOns.remove(idx);
                      } else {
                        _selectedAddOns.add(idx);
                      }
                    });
                  },
                ),
              );
            }),
          ],

          const SizedBox(height: 16),

          // Total price and buttons
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price:', style: TextStyle(fontSize: 12)),
                  Text(
                    '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAddOns = false;
                    _selectedAddOns.clear();
                    _quantity = 1;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.shopping_cart, size: 16),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isLoading ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // If in details view but not showing add-ons selection
    if (widget.isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    ),
                  )
                  : const Icon(
                    Icons.add_shopping_cart,
                    size: 16,
                    color: Colors.white,
                  ),
          label: const Text(
            'Add to Cart',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: _isLoading ? null : _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    // Default button in list view
    return ElevatedButton.icon(
      icon:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1,
                ),
              )
              : const Icon(
                Icons.add_shopping_cart,
                size: 16,
                color: Colors.white,
              ),
      label: const Text(
        'Add to Cart',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: _isLoading ? null : _addToCart,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
