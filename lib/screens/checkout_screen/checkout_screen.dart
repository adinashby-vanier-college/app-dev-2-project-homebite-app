// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  // Dummy data
  final String _itemName     = 'Qabili Palaw';
  final String _schedule     = 'Thu Apr 17, 12:00PM - 12:30PM';
  final String _addressLine1 = '1230 Rue Belmont, Montreal, QC, CA, H3B 2L9';
  final String _dropOffNote  = 'Meet at door';
  final double _foodSubtotal = 35.00;
  final double _deliveryFee  = 6.99;
  final double _taxes        = 2.10;

  @override
  Widget build(BuildContext context) {
    final double total = _foodSubtotal + _deliveryFee + _taxes;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item title & schedule
            Text(
              _itemName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Scheduled for $_schedule',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // Address card
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              child: Row(
                children: [
                  Expanded(child: Text(_addressLine1)),
                  TextButton(
                    onPressed: () {
                      // TODO: update address
                    },
                    child: const Text('update', style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Drop-off note card
            _buildInfoCard(
              icon: Icons.home_outlined,
              child: Row(
                children: [
                  Expanded(child: Text(_dropOffNote)),
                  TextButton(
                    onPressed: () {
                      // TODO: update drop-off note
                    },
                    child: const Text('update', style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // “Add a note”
            _buildInfoCard(
              icon: Icons.note_add_outlined,
              child: const Text('Add a note'),
            ),
            const SizedBox(height: 12),

            // “Enter a promo code”
            _buildInfoCard(
              icon: Icons.discount_outlined,
              child: const Text('Enter a promo code'),
            ),
            const SizedBox(height: 24),

            // Summary section
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Food Subtotal', _foodSubtotal),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Delivery Fee', _deliveryFee),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Taxes & Other Fees', _taxes),
                  const Divider(height: 24, thickness: 1),
                  _buildSummaryRow('Total', total, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment method
            _buildInfoCard(
              icon: Icons.apple,
              child: Row(
                children: [
                  const Expanded(child: Text('Apple Pay')),
                  TextButton(
                    onPressed: () {
                      // TODO: update payment method
                    },
                    child: const Text('update', style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Next button
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF0E4743),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            // TODO: proceed to payment confirmation
          },
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        const Spacer(),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
