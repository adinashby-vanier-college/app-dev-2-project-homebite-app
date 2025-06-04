import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get reference to user's cart
  static DocumentReference _getUserCartRef() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('carts').doc(userId);
  }

  // Get user's cart as a stream
  static Stream<DocumentSnapshot> getCartStream() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      return _firestore.collection('carts').doc(userId).snapshots();
    } catch (e) {
      rethrow;
    }
  }

  // Get user's cart as a future
  static Future<DocumentSnapshot> getCart() {
    try {
      return _getUserCartRef().get();
    } catch (e) {
      rethrow;
    }
  }

  // Get cart items as a list of CartItem objects
  static Future<List<CartItem>> getCartItems() async {
    try {
      final cartDoc = await getCart();
      if (!cartDoc.exists) {
        return [];
      }

      final cartData = cartDoc.data() as Map<String, dynamic>?;
      if (cartData == null) {
        return [];
      }

      final items = cartData['items'] as List<dynamic>? ?? [];
      return items
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add item to cart
  static Future<void> addToCart(CartItem item) async {
    try {
      final cartRef = _getUserCartRef();
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        // Create new cart if it doesn't exist
        await cartRef.set({
          'items': [item.toMap()],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing cart
        final items = List<Map<String, dynamic>>.from(
          cartDoc.get('items') ?? [],
        );

        // Check if item already exists in cart
        final existingItemIndex = items.indexWhere(
          (existingItem) =>
              existingItem['dishId'] == item.dishId &&
              _areAddOnsEqual(
                existingItem['addOns'] ?? [],
                item.addOns.map((addon) => addon.toMap()).toList(),
              ),
        );

        if (existingItemIndex != -1) {
          // Update existing item quantity
          items[existingItemIndex]['quantity'] += item.quantity;
        } else {
          // Add new item
          items.add(item.toMap());
        }

        // Update the cart
        await cartRef.update({
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update item quantity in cart
  static Future<void> updateItemQuantity({
    required String dishId,
    required int quantity,
    List<Map<String, dynamic>> addOns = const [],
  }) async {
    try {
      final cartRef = _getUserCartRef();
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart does not exist');
      }

      final items = List<Map<String, dynamic>>.from(cartDoc.get('items') ?? []);

      // Find the item
      final itemIndex = items.indexWhere(
        (item) =>
            item['dishId'] == dishId &&
            _areAddOnsEqual(item['addOns'] ?? [], addOns),
      );

      if (itemIndex == -1) {
        throw Exception('Item not found in cart');
      }

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        items.removeAt(itemIndex);
      } else {
        // Update quantity
        items[itemIndex]['quantity'] = quantity;
      }

      // Update the cart
      await cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart({
    required String dishId,
    List<Map<String, dynamic>> addOns = const [],
  }) async {
    try {
      final cartRef = _getUserCartRef();
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception('Cart does not exist');
      }

      final items = List<Map<String, dynamic>>.from(cartDoc.get('items') ?? []);

      // Find and remove the item
      final itemIndex = items.indexWhere(
        (item) =>
            item['dishId'] == dishId &&
            _areAddOnsEqual(item['addOns'] ?? [], addOns),
      );

      if (itemIndex == -1) {
        throw Exception('Item not found in cart');
      }

      items.removeAt(itemIndex);

      // Update the cart
      await cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Clear cart
  static Future<void> clearCart() async {
    try {
      final cartRef = _getUserCartRef();
      await cartRef.update({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to compare addOns lists
  static bool _areAddOnsEqual(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      final a = list1[i];
      final b = list2[i];

      if (a['name'] != b['name'] || a['price'] != b['price']) {
        return false;
      }
    }

    return true;
  }

  // Helper method to add a dish to cart directly
  static Future<void> addDishToCart({
    required String dishId,
    required String name,
    required double price,
    required int quantity,
    List<Map<String, dynamic>> addOns = const [],
  }) async {
    try {
      // Convert add-ons to CartItemAddOn objects
      final addOnsList =
          addOns
              .map(
                (addon) => CartItemAddOn(
                  name: addon['name'] as String,
                  price: addon['price'] as double,
                ),
              )
              .toList();

      // Create CartItem
      final cartItem = CartItem(
        dishId: dishId,
        name: name,
        price: price,
        quantity: quantity,
        addOns: addOnsList,
      );

      // Add to cart
      await addToCart(cartItem);
    } catch (e) {
      rethrow;
    }
  }

  // Get the total number of items in the cart
  static Stream<int> getCartItemCount() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Stream.value(0);
      }

      return _firestore.collection('carts').doc(userId).snapshots().map((
        snapshot,
      ) {
        if (!snapshot.exists) {
          return 0;
        }

        final cartData = snapshot.data();
        if (cartData == null) {
          return 0;
        }

        final items = cartData['items'] as List<dynamic>? ?? [];
        return items.fold<int>(
          0,
          (sum, item) => sum + (item['quantity'] as int),
        );
      });
    } catch (e) {
      return Stream.value(0);
    }
  }

  // Check if a dish is already in the cart
  static Future<bool> isDishInCart(String dishId) async {
    try {
      if (_auth.currentUser == null) {
        return false;
      }

      final cartDoc = await getCart();
      if (!cartDoc.exists) {
        return false;
      }

      final cartData = cartDoc.data() as Map<String, dynamic>?;
      if (cartData == null) {
        return false;
      }

      final items = cartData['items'] as List<dynamic>? ?? [];
      return items.any((item) => item['dishId'] == dishId);
    } catch (e) {
      return false;
    }
  }
}
