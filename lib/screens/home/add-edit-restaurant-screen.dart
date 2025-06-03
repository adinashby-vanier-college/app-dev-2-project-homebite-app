import 'package:flutter/material.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditRestaurantScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? existingData;

  const AddEditRestaurantScreen({super.key, this.restaurantId, this.existingData});

  @override
  _AddEditRestaurantScreenState createState() => _AddEditRestaurantScreenState();
}

class _AddEditRestaurantScreenState extends State<AddEditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _cookNameController;
  late TextEditingController _labelController;
  late TextEditingController _vendorController;
  late TextEditingController _ratingController;
  late TextEditingController _reviewsController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingData?['title'] ?? '');
    _locationController = TextEditingController(text: widget.existingData?['location'] ?? '');
    _cookNameController = TextEditingController(text: widget.existingData?['cookName'] ?? '');
    _labelController = TextEditingController(text: widget.existingData?['label'] ?? '');
    _vendorController = TextEditingController(text: widget.existingData?['vendor'] ?? '');
    _ratingController = TextEditingController(text: widget.existingData?['rating'] ?? '');
    _reviewsController = TextEditingController(text: widget.existingData?['reviews'] ?? '');
    _descriptionController = TextEditingController(text: widget.existingData?['description'] ?? '');
    _imageController = TextEditingController(text: widget.existingData?['image'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _cookNameController.dispose();
    _labelController.dispose();
    _vendorController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveRestaurant() async {
    if (_formKey.currentState?.validate() ?? false) {
      final restaurantData = {
        'title': _titleController.text,
        'location': _locationController.text,
        'cookName': _cookNameController.text,
        'label': _labelController.text,
        'vendor': _vendorController.text,
        'rating': _ratingController.text,
        'reviews': _reviewsController.text,
        'description': _descriptionController.text,
        'image': _imageController.text,
      };

      if (widget.restaurantId == null) {
        await FirebaseFirestore.instance.collection('restaurants').add(restaurantData);
      } else {
        await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).update(restaurantData);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantId == null ? 'Add Restaurant' : 'Edit Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter location' : null,
                ),
                TextFormField(
                  controller: _cookNameController,
                  decoration: InputDecoration(labelText: 'Cook Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter cook name' : null,
                ),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(labelText: 'Label'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter label' : null,
                ),
                TextFormField(
                  controller: _vendorController,
                  decoration: InputDecoration(labelText: 'Vendor'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter vendor' : null,
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: InputDecoration(labelText: 'Rating'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter rating' : null,
                ),
                TextFormField(
                  controller: _reviewsController,
                  decoration: InputDecoration(labelText: 'Reviews'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter reviews' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                ),
                TextFormField(
                  controller: _imageController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter image URL' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveRestaurant,
                  child: Text(widget.restaurantId == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
