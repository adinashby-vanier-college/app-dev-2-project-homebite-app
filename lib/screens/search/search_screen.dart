// lib/screens/search/search_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/restaurant_service.dart';
import '../home/food-card.dart';
import '../restaurant_details/dishes-screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];
  List<QueryDocumentSnapshot> _allRestaurants = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllRestaurants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _performSearch(_searchController.text);
  }

  Future<void> _loadAllRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await RestaurantService.getAllRestaurants();
      setState(() {
        _allRestaurants = snapshot.docs;
        _searchResults = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading restaurants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _allRestaurants;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered =
        _allRestaurants.where((restaurant) {
          final data = restaurant.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final vendor = (data['vendor'] ?? '').toString().toLowerCase();
          final label = (data['label'] ?? '').toString().toLowerCase();

          return title.contains(lowercaseQuery) ||
              vendor.contains(lowercaseQuery) ||
              label.contains(lowercaseQuery);
        }).toList();

    setState(() {
      _searchResults = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1EE),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Search Restaurants',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for restaurants, cuisines, or locations...',
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [
      'All',
      'Fast Food',
      'Italian',
      'Asian',
      'Arabic',
      'Desserts',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected:
                  false, // You can implement category filtering logic here
              onSelected: (selected) {
                // Implement category filtering
              },
              selectedColor: Colors.teal.withOpacity(0.2),
              checkmarkColor: Colors.teal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No restaurants found for "$_searchQuery"',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No restaurants available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllRestaurants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final restaurant = _searchResults[index];
          final restaurantData = restaurant.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap:
                  () => _navigateToDishes(context, restaurant, restaurantData),
              child: FoodCard(
                food: restaurantData,
                restaurantId: restaurant.id,
              ),
            ),
          );
        },
      ),
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
}
