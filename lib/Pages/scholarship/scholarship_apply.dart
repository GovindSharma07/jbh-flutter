import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class ApplyScholarshipScreen extends StatefulWidget {
  const ApplyScholarshipScreen({Key? key}) : super(key: key);

  @override
  State<ApplyScholarshipScreen> createState() => _ApplyScholarshipScreenState();
}

class _ApplyScholarshipScreenState extends State<ApplyScholarshipScreen> {
  // Define the primary color
  final Color primaryColor = const Color(0xFF003B5C);

  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _gmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController(); // For Date of Birth
  final _addressController = TextEditingController();
  final _educationController = TextEditingController();

  // State for Gender dropdown
  final List<String> _genderOptions = ['Gender', 'Male', 'Female', 'Other'];
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = _genderOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gmailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  // Helper widget to build the styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? trailingIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background from image
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          suffixIcon: trailingIcon,
        ),
      ),
    );
  }

  // Helper for the Gender Dropdown
  Widget _buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        isExpanded: true,
        items: _genderOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format the date as you like
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor, // Dark teal background
      appBar: buildAppBar(context, title: 'Apply for Scholarship'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
              ),
              _buildTextField(
                controller: _gmailController,
                labelText: 'Gmail',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone No.',
                keyboardType: TextInputType.phone,
              ),
              // Date of Birth Field
              _buildTextField(
                controller: _dobController,
                labelText: 'Date of Birth',
                readOnly: true,
                onTap: () => _selectDate(context),
                trailingIcon: const Icon(Icons.calendar_today),
              ),
              // Gender Field
              _buildGenderDropdown(),
              // Address Field
              _buildTextField(
                controller: _addressController,
                labelText: 'Address',
              ),
              // Education Field
              _buildTextField(
                controller: _educationController,
                labelText: 'Education',
              ),

              const SizedBox(height: 24),

              // --- Submit Button (Recommended) ---
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button
                  foregroundColor: primaryColor, // Dark text
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  'Submit Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      // Use your nav bar, setting an appropriate index
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}