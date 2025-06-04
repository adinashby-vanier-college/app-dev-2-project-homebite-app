import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/restaurant_service.dart';
import '../restaurant_details/dishes-screen.dart';
import 'add-edit-restaurant-screen.dart';
import 'food-card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1EE),
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.location_on, color: Colors.black),
      title: const Row(
        children: [
          Text(
            '1230 Rue Belmont',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: RestaurantService.getRestaurantsStream(),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No restaurants available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first restaurant using the + button',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final restaurants = snapshot.data!.docs;
        return _buildRestaurantsList(context, restaurants);
      },
    );
  }

  Widget _buildRestaurantsList(
    BuildContext context,
    List<QueryDocumentSnapshot> restaurants,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Force refresh by rebuilding the stream
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          final restaurantData = restaurant.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap:
                  () => _navigateToDishes(context, restaurant, restaurantData),
              onLongPress: () => _showDeleteDialog(context, restaurant.id),
              child: FoodCard(
                food: restaurantData,
                restaurantId: restaurant.id,
                onFavoriteChanged: (isFavorite) {
                  // Optional: Show a snackbar or perform other actions
                  final message =
                      isFavorite
                          ? '${restaurantData['title']} added to favorites'
                          : '${restaurantData['title']} removed from favorites';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: isFavorite ? Colors.green : Colors.grey,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddRestaurant(context),
      backgroundColor: Colors.teal,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToDishes(
    BuildContext context,
    QueryDocumentSnapshot restaurant,
    Map<String, dynamic> restaurantData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DishesScreen(
              item: {
                'restaurantId': restaurant.id,
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

  void _navigateToAddRestaurant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditRestaurantScreen()),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    String restaurantId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Restaurant'),
            content: const Text(
              'Are you sure you want to delete this restaurant? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _deleteRestaurant(context, restaurantId);
    }
  }

  Future<void> _deleteRestaurant(
    BuildContext context,
    String restaurantId,
  ) async {
    try {
      await RestaurantService.deleteRestaurant(restaurantId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting restaurant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
