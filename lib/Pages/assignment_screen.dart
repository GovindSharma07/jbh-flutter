import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  // 0 = Submission, 1 = Status
  int _selectedTabIndex = 1; // Default to 'Status' as selected

  // Define the primary color
  final Color primaryColor = const Color(0xFF003B5C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: Column(
        children: [
          // --- Tab Button Row ---
          Padding(
            padding: EdgeInsets.fromLTRB(16,16,16,0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assignments',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Submission', 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton('Status', 1),
                ),
              ],
            ),
          ),

          // --- Conditional Tab Content ---
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      bottomNavigationBar:FloatingCustomNavBar(),
    );
  }

  // Helper widget to build the tab buttons
  Widget _buildTabButton(String title, int index) {
    final bool isSelected = (_selectedTabIndex == index);

    return isSelected
        ? ElevatedButton(
      onPressed: () {
        setState(() => _selectedTabIndex = index);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    )
        : OutlinedButton(
      onPressed: () {
        setState(() => _selectedTabIndex = index);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper widget to show the correct content
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Submission
        return const Center(
          child: Text(
            'Submitted assignments will appear here.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        );
      case 1: // Status (As shown in the image)
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ReusableAssignmentCard(
              title: 'Python Assignment 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              dueDate: 'Due date: 26 oct, 2024, 11:59',
              primaryColor: primaryColor,
              onButtonPressed: () {
                // Handle Submit Now
              },
            ),
            const SizedBox(height: 16),
            ReusableAssignmentCard(
              title: 'Python Assignment 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              dueDate: 'Due date: 26 oct, 2024, 11:59',
              primaryColor: primaryColor,
              onButtonPressed: () {
                // Handle Submit Now
              },
            ),
            const SizedBox(height: 16),
            ReusableAssignmentCard(
              title: 'Python Assignment 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              dueDate: 'Due date: 26 oct, 2024, 11:59',
              primaryColor: primaryColor,
              onButtonPressed: () {
                // Handle Submit Now
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }
}

// --- Reusable Assignment Card Widget ---
class ReusableAssignmentCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String date;
  final String dueDate;
  final Color primaryColor;
  final VoidCallback onButtonPressed;

  const ReusableAssignmentCard({
    Key? key,
    required this.title,
    required this.instructor,
    required this.date,
    required this.dueDate,
    required this.primaryColor,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
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
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dueDate,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red, // Due date in red
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400], // Greyish button
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit Now'),
            ),
          ],
        ),
      ),
    );
  }
}