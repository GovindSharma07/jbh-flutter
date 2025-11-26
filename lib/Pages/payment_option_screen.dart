import 'package:flutter/material.dart';

class PaymentOptionScreen extends StatefulWidget {
  const PaymentOptionScreen({super.key});

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

// Enum to hold the payment method options
enum PaymentMethod {
  card,
  upi,
  netbanking,
  transfer,
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  // This variable holds the currently selected payment method.
  // We'll set 'card' as the default selected one, as in your image.
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    // Define the primary color for buttons and selection
    const Color primaryColor = Color(0xFF003B5C); // A dark blue

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Payment Options',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Re-usable widget for payment options
            PaymentOptionTile(
              title: 'Credit or Debit card',
              value: PaymentMethod.card,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 12),
            PaymentOptionTile(
              title: 'UPI Wallets',
              value: PaymentMethod.upi,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 12),
            PaymentOptionTile(
              title: 'Net Banking',
              value: PaymentMethod.netbanking,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 12),
            PaymentOptionTile(
              title: 'Bank Transfer',
              value: PaymentMethod.transfer,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Code Entry Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Code',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle Apply Now
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white70),
                  ),
                ),
              ],
            ),

            // This Spacer pushes the button to the bottom
            const Spacer(),

            // Pay Now Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle Pay Now action
                },
                icon: const Icon(Icons.shield_outlined, color: Colors.white),
                label: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget to create the styled RadioListTile
class PaymentOptionTile extends StatelessWidget {
  final String title;
  final PaymentMethod value;
  final PaymentMethod? groupValue;
  final ValueChanged<PaymentMethod?> onChanged;

  const PaymentOptionTile({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF005A8D);
    bool isSelected = (value == groupValue);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: RadioListTile<PaymentMethod>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? primaryColor : Colors.black87,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: primaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}