import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../app_routes.dart';

class ScoreResultsScreen extends StatelessWidget {
  const ScoreResultsScreen({super.key});

  // Helper function to build the styled buttons
  Widget _buildResultButton({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        // Dark blue color
        minimumSize: const Size(double.infinity, 56),
        // Full width, fixed height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary color
    Color primaryColor = Theme
        .of(context)
        .primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildResultButton(
              context: context,
              title: 'Scholarship Result',
              color: primaryColor,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.scholarshipResult,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildResultButton(
              context: context,
              title: 'Quizes Result', // Spelling from image
              color: primaryColor,
              onPressed: () {
                // Navigate to Quizzes Result Screen
                Navigator.pushNamed(
                    context,
                    AppRoutes.quizzesResult
                );
              },
            ),
            const SizedBox(height: 16),
            _buildResultButton(
              context: context,
              title: 'Weekly Test Results', // Typo from image
              color: primaryColor,
              onPressed: () {
                // Navigate to the Weekly Test screen
                Navigator.pushNamed(
                    context,
                    AppRoutes.weeklyTest
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}
