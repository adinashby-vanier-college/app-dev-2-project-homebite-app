import 'package:flutter/material.dart';


class FoodCard extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  food['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, color: Colors.red),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    food['label'],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(food['vendor'], style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text('${food['rating']} (${food['reviews']})'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}