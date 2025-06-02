// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Preset tip amounts
  final List<double> _tipOptions = [4.0, 5.0, 6.0];
  double? _selectedTip;
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectTip(double? tip) {
    setState(() {
      _selectedTip = tip;
      if (tip != null && tip != -1) {
        _customController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & subtitle
              const Text(
                'Tip your cook & driver',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share the love when you evenly split your tip '
                    'between the chef and the delivery driver.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Tip options row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Preset amounts
                  for (var amt in _tipOptions)
                    _buildTipButton(
                      label: '\$${amt.toInt()}',
                      isSelected: _selectedTip == amt,
                      onTap: () => _selectTip(amt),
                    ),

                  // Custom
                  _selectedTip == -1
                      ? SizedBox(
                    width: 70,
                    height: 40,
                    child: TextField(
                      controller: _customController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '\$Custom',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          _selectTip(parsed);
                        }
                      },
                    ),
                  )
                      : _buildTipButton(
                    label: '\$Custom',
                    isSelected: false,
                    onTap: () => _selectTip(-1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom “Order with Apple Pay” bar
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF0E4743),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: TextButton.icon(
          icon: const Icon(Icons.apple, color: Colors.white),
          label: const Text(
            'Order with Apple Pay',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            // TODO: trigger payment
            final tip = _selectedTip ?? 0.0;
            debugPrint('Ordering with tip: \$${tip.toStringAsFixed(2)}');
          },
        ),
      ),
    );
  }

  Widget _buildTipButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E4743) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
