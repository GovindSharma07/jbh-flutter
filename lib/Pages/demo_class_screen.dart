// 1. Convert to a StatefulWidget to manage dropdowns
import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class DemoClassScreen extends StatefulWidget {
  const DemoClassScreen({Key? key}) : super(key: key);

  @override
  State<DemoClassScreen> createState() => _DemoClassScreenState();
}

class _DemoClassScreenState extends State<DemoClassScreen> {
  // Define the primary color
  final Color primaryColor = const Color(0xFF003B5C);

  // Lists for dropdown options
  final List<String> _filterOptions = [
    'Filter By Sub',
    'Python Django',
    'Data Analyst',
    'All Subjects',
  ];
  final List<String> _sortOptions = [
    'Sort By Newest',
    'Sort By Oldest',
    'By Name (A-Z)',
  ];

  // State variables to hold the selected value
  String? _selectedFilter;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    // Set the initial selected value
    _selectedFilter = _filterOptions.first;
    _selectedSort = _sortOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Demo Class',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // --- Filter and Sort Row ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedFilter,
                      isExpanded: true,
                      items: _filterOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      isExpanded: true,
                      items: _sortOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSort = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                    ),
                  ), // Pushes buttons to the left
                ],
              ),
              const SizedBox(height: 20),

              // --- Demo Class List ---
              DemoClassCard(
                title: 'Python Django',
                instructor: 'Mr. Ashish Singh',
                // Make sure to add this image to your assets
                imagePath: 'assets/demo_class_teacher.jpg',
              ),
              const SizedBox(height: 16),
              DemoClassCard(
                title: 'Python Django',
                instructor: 'Mr. Ashish Singh',
                // Make sure to add this image to your assets
                imagePath: 'assets/demo_class_math.jpg',
              ),
              const SizedBox(height: 16),
              // Add more DemoClassCards as needed
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}

// --- Reusable Demo Class Card Widget ---
class DemoClassCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String imagePath;

  const DemoClassCard({
    Key? key,
    required this.title,
    required this.instructor,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // This clips the content inside (e.g., the image) to the card's shape
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image and Button Stack ---
          Stack(
            children: [
              Image.asset(
                imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // Error builder for placeholder
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Join Demo Class
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(), // Pill shape
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Join Demo Class',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- Text Content Below Image ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructor,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
