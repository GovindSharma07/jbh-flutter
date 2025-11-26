import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/app_routes.dart';

class UpcomingScholarshipScreen extends StatefulWidget {
  const UpcomingScholarshipScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingScholarshipScreen> createState() =>
      _UpcomingScholarshipScreenState();
}

class _UpcomingScholarshipScreenState extends State<UpcomingScholarshipScreen> {
  // Define the primary color

  // Lists for dropdown options
  final List<String> _filterOptions = ['Upcoming', 'Past', 'All'];
  final List<String> _typeOptions = ['My', 'All', 'Applied'];

  // State variables to hold the selected value
  String? _selectedFilter;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // Set the initial selected value
    _selectedFilter = _filterOptions.first;
    _selectedType = _typeOptions.first;
  }

  @override
  Widget build(BuildContext context) {

    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Use your common app bar
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Scholarship',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 16,),
              // --- Filter and Sort Row ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildFilterDropdown(
                        _selectedFilter, _filterOptions, (val) {
                      setState(() => _selectedFilter = val);
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildFilterDropdown(_selectedType, _typeOptions,
                            (val) {
                          setState(() => _selectedType = val);
                        }),
                  ),
                  const Spacer(flex: 1), // Pushes buttons to the left
                ],
              ),
              const SizedBox(height: 20),

              // --- Scholarship List ---
              _ScholarshipCard(
                title: 'Python Django',
                applyDate: 'Apply before: 25 Nov 2025',
                date: '8 OCT 2025',
                primaryColor: primaryColor,
                onApply: () {
                  // Navigate to apply screen
                  Navigator.pushNamed(context, AppRoutes.applyScholarship);
                },
              ),
              const SizedBox(height: 16),
              _ScholarshipCard(
                title: 'Python Django',
                applyDate: 'Apply before: 25 Nov 2025',
                date: '8 OCT 2025',
                primaryColor: primaryColor,
                onApply: () {
                  // Navigate to apply screen
                  Navigator.pushNamed(context, AppRoutes.applyScholarship);
                },
              ),
            ],
          ),
        ),
      ),
      // Use your nav bar, setting an appropriate index (e.g., 0 for Home)
      bottomNavigationBar: FloatingCustomNavBar(currentIndex: 0),
    );
  }

  // Helper widget for building the styled dropdowns
  Widget _buildFilterDropdown(
      String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((String value) {
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
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
    );
  }
}

// --- Reusable Scholarship Card Widget ---
class _ScholarshipCard extends StatelessWidget {
  final String title;
  final String applyDate;
  final String date;
  final Color primaryColor;
  final VoidCallback onApply;

  const _ScholarshipCard({
    Key? key,
    required this.title,
    required this.applyDate,
    required this.date,
    required this.primaryColor,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Title, Apply Date, Button
            Expanded(
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
                    applyDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Apply Now',style: TextStyle(color: Colors.white70),),
                  ),
                ],
              ),
            ),
            // Right Column: Date, Status Chip
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'End Soon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}