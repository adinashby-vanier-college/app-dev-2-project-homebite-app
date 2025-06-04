import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEditRestaurantScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? existingData;

  const AddEditRestaurantScreen({
    super.key,
    this.restaurantId,
    this.existingData,
  });

  @override
  _AddEditRestaurantScreenState createState() =>
      _AddEditRestaurantScreenState();
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
  bool _isLoading = false;

  // Define our custom theme colors

  final Color _accentColor = Colors.teal; // green-500
  final Color _backgroundColor = const Color(0xFFF4F4F5); // zinc-100
  final Color _surfaceColor = Colors.white;
  final Color _errorColor = const Color(0xFFEF4444); // red-500
  final Color _textColor = const Color(0xFF18181B); // zinc-900
  final Color _secondaryTextColor = const Color(0xFF71717A); // zinc-500

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingData?['title'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.existingData?['location'] ?? '',
    );
    _cookNameController = TextEditingController(
      text: widget.existingData?['cookName'] ?? '',
    );
    _labelController = TextEditingController(
      text: widget.existingData?['label'] ?? '',
    );
    _vendorController = TextEditingController(
      text: widget.existingData?['vendor'] ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.existingData?['rating'] ?? '',
    );
    _reviewsController = TextEditingController(
      text: widget.existingData?['reviews'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingData?['description'] ?? '',
    );
    _imageController = TextEditingController(
      text: widget.existingData?['image'] ?? '',
    );
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
      setState(() {
        _isLoading = true;
      });

      try {
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
          await FirebaseFirestore.instance
              .collection('restaurants')
              .add(restaurantData);
        } else {
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(widget.restaurantId)
              .update(restaurantData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.restaurantId == null
                  ? 'Restaurant added successfully!'
                  : 'Restaurant updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: _errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15, color: _textColor),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon,
              hintStyle: TextStyle(color: _secondaryTextColor),
              filled: true,
              fillColor: _surfaceColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _errorColor, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _errorColor, width: 1.5),
              ),
            ),
            validator:
                (value) => value == null || value.isEmpty ? errorText : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdding = widget.restaurantId == null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          isAdding ? 'Add Restaurant' : 'Edit Restaurant',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: _accentColor))
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAdding
                                      ? 'Add New Restaurant'
                                      : 'Update Restaurant Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Fill in the details below to create a new restaurant listing',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Basic Information Section
                          _buildSectionCard(
                            title: 'Basic Information',
                            children: [
                              _buildTextField(
                                controller: _titleController,
                                label: 'Restaurant Name',
                                errorText: 'Please enter restaurant name',
                                hintText: 'Enter restaurant name',
                                prefixIcon: Icon(
                                  Icons.restaurant,
                                  color: _secondaryTextColor,
                                ),
                              ),
                              _buildTextField(
                                controller: _locationController,
                                label: 'Location',
                                errorText: 'Please enter location',
                                hintText: 'Enter restaurant location',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: _secondaryTextColor,
                                ),
                              ),
                              _buildTextField(
                                controller: _cookNameController,
                                label: 'Cook Name',
                                errorText: 'Please enter cook name',
                                hintText: 'Enter cook name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: _secondaryTextColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Details Section
                          _buildSectionCard(
                            title: 'Restaurant Details',
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _labelController,
                                      label: 'Label',
                                      errorText: 'Please enter label',
                                      hintText: 'e.g., Italian, Chinese',
                                      prefixIcon: Icon(
                                        Icons.label,
                                        color: _secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _vendorController,
                                      label: 'Vendor',
                                      errorText: 'Please enter vendor',
                                      hintText: 'Enter vendor name',
                                      prefixIcon: Icon(
                                        Icons.store,
                                        color: _secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _ratingController,
                                      label: 'Rating',
                                      errorText: 'Please enter rating',
                                      hintText: '0.0 - 5.0',
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icon(
                                        Icons.star,
                                        color: _secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _reviewsController,
                                      label: 'Reviews Count',
                                      errorText: 'Please enter reviews count',
                                      hintText: 'Enter number of reviews',
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icon(
                                        Icons.rate_review,
                                        color: _secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Media Section
                          _buildSectionCard(
                            title: 'Media & Description',
                            children: [
                              _buildTextField(
                                controller: _imageController,
                                label: 'Image URL',
                                errorText: 'Please enter image URL',
                                hintText: 'Enter image URL',
                                prefixIcon: Icon(
                                  Icons.image,
                                  color: _secondaryTextColor,
                                ),
                              ),
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                errorText: 'Please enter description',
                                hintText: 'Enter restaurant description',
                                maxLines: 4,
                              ),
                            ],
                          ),

                          // Submit Button
                          SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _saveRestaurant,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: Text(
                                isAdding
                                    ? 'Add Restaurant'
                                    : 'Update Restaurant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          SizedBox(height: 4),
          Divider(height: 24, thickness: 1, color: Colors.grey.shade200),
          ...children,
        ],
      ),
    );
  }
}
