import 'package:flutter/material.dart';

import '../restaurant_details/dishes-screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add-edit-restaurant-screen.dart';
import 'food-card.dart';

class HomeScreen extends StatelessWidget {
  final Stream<QuerySnapshot> restaurantsStream = FirebaseFirestore.instance.collection('restaurants').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.location_on, color: Colors.black),
        title: const Row(
          children: [
            Text('1230 Rue Belmont', style: TextStyle(color: Colors.black)),
            Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: restaurantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No restaurants available'));
          }

          final restaurants = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final restaurantData = restaurants[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishesScreen(item: {
                        'restaurantId': restaurant.id,
                        'image': restaurantData['image'],
                        'title': restaurantData['title'],
                        'location': restaurantData['label'],
                        'cookName': restaurantData['vendor'],
                        'rating': restaurantData['rating'].toString(),
                        'reviews': restaurantData['reviews'].toString(),
                        'description': 'Delicious food prepared with care.', // Add a description
                      }),
                    ),
                  );
                },
                child: FoodCard(food: restaurantData),
                onLongPress: () async {
                    await showRestaurantDeleteDialog(context, restaurant.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditRestaurantScreen(),
            ),
          );
          },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Future<void> showRestaurantDeleteDialog(BuildContext context, String restaurantId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: const Text('Are you sure you want to delete this restaurant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == null || !confirm) return;

    await FirebaseFirestore.instance.collection('restaurants').doc(restaurantId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant deleted')),
    );
  }
}