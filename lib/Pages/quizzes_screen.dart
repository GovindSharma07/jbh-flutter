import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
// Make sure you have your common app bar and nav bar imports
// import 'package:jbh_academy/Components/common_app_bar.dart';
// import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  // 0 = Submission, 1 = Status
  int _selectedTabIndex = 1; // Default to 'Status' as selected


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Using a placeholder AppBar. Replace with your buildAppBar(context, title: 'Quizzes')
      appBar: buildAppBar(context),
      body: Column(
        children: [
          // --- Tab Button Row ---
          Padding(
            padding: EdgeInsets.fromLTRB(16,16,16,0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quizzes',
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
                  child: _buildTabButton('Submission', 0,primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton('Status', 1,primaryColor),
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
      // Using a placeholder BottomNavBar. Replace with your FloatingCustomNavBar()
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  // Helper widget to build the tab buttons
  Widget _buildTabButton(String title, int index,Color primaryColor) {
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
            'Submitted quizzes will appear here.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        );
      case 1: // Status (As shown in the image)
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // --- Card 1: Live Quiz ---
            QuizStatusCard(
              title: 'Python Quiz 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              details: const Text(
                'Due date: 26 oct,2024, 11:59',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red, // Due date in red
                  fontWeight: FontWeight.w500,
                ),
              ),
              // --- Custom Action Row ---
              actionRow: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle Start Quiz
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400], // Greyish button
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    // Changed from "Quizzes" to "Start Quiz"
                    child: const Text('Start Quiz'),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● Live Now',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Card 2: Timed ---
            QuizStatusCard(
              title: 'Python Quiz 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              details: const Text(
                'Timing: 1:10PM',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              actionRow: null, // No action row
            ),
            const SizedBox(height: 16),

            // --- Card 3: Timed ---
            QuizStatusCard(
              title: 'Python Quiz 1',
              instructor: 'MR: Ashish Singh',
              date: '8 oct 2025',
              details: const Text(
                'Timing: 11:59',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              actionRow: null, // No action row
            ),
          ],
        );
      default:
        return Container();
    }
  }
}

// --- Reusable Quiz Status Card Widget ---
class QuizStatusCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String date;
  final Widget details;
  final Widget? actionRow; // Optional widget for the bottom row

  const QuizStatusCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.date,
    required this.details,
    this.actionRow,
  });

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
            details, // Display the details widget
            const SizedBox(height: 16),
            if (actionRow != null)
              actionRow!, // Display the action row if it's not null
          ],
        ),
      ),
    );
  }
}