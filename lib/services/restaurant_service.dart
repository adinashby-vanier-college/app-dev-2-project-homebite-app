import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _restaurantsCollection = _firestore
      .collection('restaurants');

  // Get a stream of all restaurants
  static Stream<QuerySnapshot> getRestaurantsStream() {
    // Using the same query that was working in the original code
    return _restaurantsCollection
        .limit(5) // تحديد عدد المطاعم إلى 5 فقط في البداية
        .snapshots();
  }

  // Get all restaurants as a future
  static Future<QuerySnapshot> getAllRestaurants() {
    return _restaurantsCollection.get();
  }

  // Get restaurant by ID
  static Future<DocumentSnapshot> getRestaurantById(String restaurantId) {
    return _restaurantsCollection.doc(restaurantId).get();
  }

  // Add a new restaurant
  static Future<DocumentReference> addRestaurant(
    Map<String, dynamic> restaurantData,
  ) {
    // Add current timestamp
    restaurantData['createdAt'] = FieldValue.serverTimestamp();
    restaurantData['updatedAt'] = FieldValue.serverTimestamp();

    return _restaurantsCollection.add(restaurantData);
  }

  // Update an existing restaurant
  static Future<void> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> restaurantData,
  ) {
    // Update timestamp
    restaurantData['updatedAt'] = FieldValue.serverTimestamp();

    return _restaurantsCollection.doc(restaurantId).update(restaurantData);
  }

  // Delete a restaurant
  static Future<void> deleteRestaurant(String restaurantId) {
    return _restaurantsCollection.doc(restaurantId).delete();
  }

  // Get restaurants by category
  static Stream<QuerySnapshot> getRestaurantsByCategory(String category) {
    return _restaurantsCollection
        .where('categories', arrayContains: category)
        .snapshots();
  }

  // Get featured restaurants
  static Stream<QuerySnapshot> getFeaturedRestaurants() {
    return _restaurantsCollection
        .where('isFeatured', isEqualTo: true)
        .limit(5)
        .snapshots();
  }

  // Search restaurants by name, vendor, or label
  static Future<QuerySnapshot> searchRestaurants(String query) {
    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();

    // Search by title
    return _restaurantsCollection
        .orderBy('title')
        .startAt([lowercaseQuery])
        .endAt(['$lowercaseQuery\uf8ff'])
        .get();
  }

  // Get restaurant dishes
  static Stream<QuerySnapshot> getRestaurantDishes(String restaurantId) {
    return _firestore
        .collection('dishes')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots();
  }
}
