import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

// 1. Create a StatefulWidget to manage dropdown state
class RecordedLecturesScreen extends StatefulWidget {
  const RecordedLecturesScreen({super.key});

  @override
  State<RecordedLecturesScreen> createState() => _RecordedLecturesScreenState();
}

class _RecordedLecturesScreenState extends State<RecordedLecturesScreen> {
  // Define the primary color
  final Color primaryColor = const Color(0xFF003B5C);

  // 2. Define lists for dropdown options
  final List<String> _subOptions = ['Sub', 'Python', 'Data Science', 'React'];
  final List<String> _dateOptions = [
    'Date',
    'Today',
    'This Week',
    'This Month',
  ];
  final List<String> _teacherOptions = ['Teacher', 'Mr. Ashish Singh', 'Other'];

  // 3. Define state variables to hold selected values
  String? _selectedSub;
  String? _selectedDate;
  String? _selectedTeacher;

  @override
  void initState() {
    super.initState();
    // 4. Set initial selected values to the hints
    _selectedSub = _subOptions.first;
    _selectedDate = _dateOptions.first;
    _selectedTeacher = _teacherOptions.first;
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
                  'Recorded Lectures',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // --- 5. Filter Dropdown Row ---
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(_selectedSub, _subOptions, (
                      val,
                    ) {
                      setState(() => _selectedSub = val);
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(_selectedDate, _dateOptions, (
                      val,
                    ) {
                      setState(() => _selectedDate = val);
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(
                      _selectedTeacher,
                      _teacherOptions,
                      (val) {
                        setState(() => _selectedTeacher = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 6. List of Lecture Cards ---
              RecordedLectureCard(
                title: 'Python Lecture 1',
                instructor: 'MR: Ashish Singh',
                date: '8 oct 2025',
                primaryColor: primaryColor,
                onWatchNow: () {},
                onDownload: () {},
              ),
              const SizedBox(height: 16),
              RecordedLectureCard(
                title: 'Python Lecture 2',
                instructor: 'MR: Ashish Singh',
                date: '8 oct 2025',
                primaryColor: primaryColor,
                onWatchNow: () {},
                onDownload: () {},
              ),
              const SizedBox(height: 16),
              RecordedLectureCard(
                title: 'Python Lecture 3',
                instructor: 'MR: Ashish Singh',
                date: '8 oct 2025',
                primaryColor: primaryColor,
                onWatchNow: () {},
                onDownload: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  // Helper widget for building the styled dropdowns
  Widget _buildFilterDropdown(
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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
              fontSize: 14, // Slightly smaller to fit
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
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
    );
  }
}

// --- Reusable Recorded Lecture Card Widget ---
class RecordedLectureCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String date;
  final Color primaryColor;
  final VoidCallback onWatchNow;
  final VoidCallback onDownload;

  const RecordedLectureCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.date,
    required this.primaryColor,
    required this.onWatchNow,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Left Column (Text & Button) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    instructor,
                    style: TextStyle(fontSize: 14, color: primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onWatchNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColorLight, // Greyish button
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Watch Now'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // --- Right Column (Image & Download) ---
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image Placeholder
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[400], size: 50),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    Icons.download_outlined,
                    color: primaryColor,
                    size: 28,
                  ),
                  onPressed: onDownload,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
