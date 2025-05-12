import 'package:flutter/material.dart';

class DishesScreen extends StatelessWidget {
  final Map<String, String> item;

  DishesScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  item['image']!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text(item['location']!),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(item['image']!),
                      ),
                      SizedBox(width: 8),
                      Text(
                        item['cookName']!,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.amber),
                      Text('${item['rating']} (${item['reviews']})'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    item['description']!,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('This cook is available for pre-orders'),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Availability',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Chip(label: Text('Thu Apr 17\n10:00AM - 6:00PM')),
                      Chip(label: Text('Sun Apr 20\n10:00AM - 6:00PM')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}