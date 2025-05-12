import 'package:flutter/material.dart';

import '../restaurant_details/dishes-screen.dart';
import 'food-card.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> foodList = [
    {
      'image': 'assets/images/qabili.png',
      'title': 'Qabili Palaw',
      'vendor': 'By Qabili',
      'rating': 4.9,
      'reviews': 19,
      'label': 'Afghan Waton',
    },
    {
      'image': 'assets/images/kebab.png',
      'title': 'Kebab Antep',
      'vendor': 'By Antep',
      'rating': 4.6,
      'reviews': 50,
      'label': 'Kebab Antep',
    },
  ];

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Available Later Today',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          ...foodList.map((food) => GestureDetector(
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
          )).toList(),        ],
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