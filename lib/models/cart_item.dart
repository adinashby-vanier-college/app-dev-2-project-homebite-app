class CartItem {
  final String dishId;
  final String name;
  final double price;
  int quantity;
  final List<CartItemAddOn> addOns;

  CartItem({
    required this.dishId,
    required this.name,
    required this.price,
    required this.quantity,
    this.addOns = const [],
  });

  // Calculate total price for this item (including addons)
  double get totalPrice {
    double addOnsTotal = 0;
    for (var addon in addOns) {
      addOnsTotal += addon.price;
    }
    return (price * quantity) + addOnsTotal;
  }

  // Create CartItem from Firestore data
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      dishId: map['dishId'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      addOns:
          (map['addOns'] as List?)
              ?.map((addon) => CartItemAddOn.fromMap(addon))
              .toList() ??
          [],
    );
  }

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'addOns': addOns.map((addon) => addon.toMap()).toList(),
    };
  }
}

class CartItemAddOn {
  final String name;
  final double price;

  CartItemAddOn({required this.name, required this.price});

  // Create CartItemAddOn from Firestore data
  factory CartItemAddOn.fromMap(Map<String, dynamic> map) {
    return CartItemAddOn(
      name: map['name'] as String,
      price: map['price'] as double,
    );
  }

  // Convert CartItemAddOn to Map for Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }
}
