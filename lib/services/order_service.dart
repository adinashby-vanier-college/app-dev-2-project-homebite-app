import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _ordersCollection = _firestore.collection(
    'orders',
  );

  // Get all orders for a user
  static Stream<QuerySnapshot> getUserOrdersStream(String userId) {
    return _ordersCollection.where('userId', isEqualTo: userId).snapshots();
  }

  // Get orders by status for a user
  static Stream<QuerySnapshot> getUserOrdersByStatusStream(
    String userId,
    String status,
  ) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // Get order by ID
  static Future<DocumentSnapshot> getOrderById(String orderId) {
    return _ordersCollection.doc(orderId).get();
  }

  // Create a new order
  static Future<DocumentReference> createOrder(Map<String, dynamic> orderData) {
    // Add timestamps
    orderData['orderDate'] = FieldValue.serverTimestamp();
    orderData['updatedAt'] = FieldValue.serverTimestamp();

    // Set initial status if not provided
    if (!orderData.containsKey('status')) {
      orderData['status'] = 'processing';
    }

    return _ordersCollection.add(orderData);
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, String status) {
    return _ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update order
  static Future<void> updateOrder(
    String orderId,
    Map<String, dynamic> orderData,
  ) {
    // Update timestamp
    orderData['updatedAt'] = FieldValue.serverTimestamp();

    return _ordersCollection.doc(orderId).update(orderData);
  }

  // Delete order (usually just for admin purposes)
  static Future<void> deleteOrder(String orderId) {
    return _ordersCollection.doc(orderId).delete();
  }

  // Get recent orders for a restaurant
  static Stream<QuerySnapshot> getRestaurantOrdersStream(String restaurantId) {
    return _ordersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }

  // Get restaurant orders by status
  static Stream<QuerySnapshot> getRestaurantOrdersByStatusStream(
    String restaurantId,
    String status,
  ) {
    return _ordersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', isEqualTo: status)
        .snapshots();
  }
}
