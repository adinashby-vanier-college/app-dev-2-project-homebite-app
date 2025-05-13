import 'package:flutter/material.dart';

import '../restaurant_details/dishes-screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              final food = restaurants[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishesScreen(item: {
                        'image': food['image'],
                        'title': food['title'],
                        'location': food['label'],
                        'cookName': food['vendor'],
                        'rating': food['rating'].toString(),
                        'reviews': food['reviews'].toString(),
                        'description': 'Delicious food prepared with care.', // Add a description
                      }),
                    ),
                  );
                },
                child: FoodCard(food: food),
              );
            },
          );
        },
        // children: [
        //   const Text(
        //     'Available Later Today',
        //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        //   ),
        //   const SizedBox(height: 16),
        //   ...restaurants.map((food) => GestureDetector(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => DishesScreen(item: {
        //             'image': food['image'],
        //             'title': food['title'],
        //             'location': food['label'],
        //             'cookName': food['vendor'],
        //             'rating': food['rating'].toString(),
        //             'reviews': food['reviews'].toString(),
        //             'description': 'Delicious food prepared with care.', // Add a description
        //           }),
        //         ),
        //       );
        //     },
        //     child: FoodCard(food: food),
        //   )).toList(),        ],
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
}