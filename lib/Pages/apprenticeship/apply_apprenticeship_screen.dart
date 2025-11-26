import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class ApplyApprenticeshipScreen extends StatefulWidget {
  const ApplyApprenticeshipScreen({super.key});

  @override
  State<ApplyApprenticeshipScreen> createState() =>
      _ApplyApprenticeshipScreenState();
}

class _ApplyApprenticeshipScreenState extends State<ApplyApprenticeshipScreen> {
  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gmailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _gmailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Helper widget to build the styled form fields
  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? trailingIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: trailingIcon != null
              ? Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: trailingIcon,
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildFormField(
                controller: _nameController,
                hintText: 'Name',
              ),
              _buildFormField(
                controller: _phoneController,
                hintText: 'Phone no:',
                keyboardType: TextInputType.phone,
              ),
              _buildFormField(
                controller: _gmailController,
                hintText: 'Gmail',
                keyboardType: TextInputType.emailAddress,
              ),
              // --- Special "Upload Resume" Field ---
              _buildFormField(
                // Use a controller if you want to display the file name
                controller: TextEditingController(),
                hintText: 'Upload Resume',
                readOnly: true,
                onTap: () {
                  // --- Handle file picking logic here ---
                  print('Upload Resume Tapped');
                },
                trailingIcon: Icon(
                  Icons.upload_file,
                  color: primaryColor,
                ),
              ),
              // --- Multi-line Text Field ---
              _buildFormField(
                controller: _messageController,
                hintText: 'Message (Optional)',
                maxLines: 5,
              ),

              const SizedBox(height: 24),

              // --- Submit Button (Recommended) ---
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  final name = _nameController.text;
                  final phone = _phoneController.text;
                  final gmail = _gmailController.text;
                  print('Name: $name, Phone: $phone, Gmail: $gmail');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  'Submit Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}