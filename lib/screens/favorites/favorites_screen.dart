import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/restaurant_service.dart';
import '../home/food-card.dart';
import '../restaurant_details/dishes-screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  void _navigateToDishes(
    BuildContext context,
    Map<String, dynamic> restaurantData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DishesScreen(
              item: {
                'restaurantId': restaurantData['id'],
                'image': restaurantData['image'] ?? '',
                'title': restaurantData['title'] ?? 'Unknown Restaurant',
                'location': restaurantData['label'] ?? 'Unknown Location',
                'cookName': restaurantData['vendor'] ?? 'Unknown Vendor',
                'rating': (restaurantData['rating'] ?? 0).toString(),
                'reviews': (restaurantData['reviews'] ?? 0).toString(),
                'description':
                    restaurantData['description'] ??
                    'Delicious food prepared with care.',
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF1EE),
        appBar: AppBar(
          title: const Text(
            'My Favorites',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Please login to view your favorites',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1EE),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(_userId)
                .collection('favorites')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add restaurants to your favorites',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final favoriteIds = snapshot.data!.docs;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRestaurantDetails(favoriteIds),
            builder: (context, restaurantsSnapshot) {
              if (restaurantsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (restaurantsSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading restaurants: ${restaurantsSnapshot.error}',
                  ),
                );
              }

              final restaurants = restaurantsSnapshot.data ?? [];
              if (restaurants.isEmpty) {
                return const Center(
                  child: Text('No restaurant data available'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => _navigateToDishes(context, restaurant),
                      child: FoodCard(
                        food: restaurant,
                        restaurantId: restaurant['id'],
                        onFavoriteChanged: (isFavorite) {
                          // Removed manual state update as StreamBuilder will handle updates
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRestaurantDetails(
    List<QueryDocumentSnapshot> favoriteIds,
  ) async {
    final List<Map<String, dynamic>> restaurants = [];

    for (final doc in favoriteIds) {
      try {
        final restaurantId =
            doc.data() is Map
                ? (doc.data() as Map<String, dynamic>)['restaurantId'] as String
                : doc.id;

        final restaurantDoc = await RestaurantService.getRestaurantById(
          restaurantId,
        );

        if (restaurantDoc.exists) {
          final restaurantData = restaurantDoc.data() as Map<String, dynamic>;
          restaurants.add({...restaurantData, 'id': restaurantId});
        }
      } catch (e) {
        print('Error fetching restaurant: $e');
      }
    }

    return restaurants;
  }
}
