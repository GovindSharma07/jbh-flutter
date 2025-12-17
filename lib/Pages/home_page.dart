import 'package:flutter/material.dart';

import '../Components/common_app_bar.dart';
import '../Components/floating_custom_nav_bar.dart';
import '../app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        // The main SingleChildScrollView's child is a Column
        child: Column(
          children: [
            Image.asset(
              'assets/images/dashboard_image.png',
              // <-- Your full banner image
              width: double.infinity,
              // Makes the image span the full width
              fit: BoxFit
                  .fitWidth, // Scales the image to fit the width, adjusting height proportionally
            ),
            const SizedBox(height: 24),

            // 2. Padding is now applied only to the content *below* the banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildWideButton(context, "Score & Rank Calculator / Result"),
                  const SizedBox(height: 24),
                  _buildGridMenu(context),
                  const SizedBox(height: 24),
                  _buildWideButton(context, "Apprenticeships"),
                  const SizedBox(height: 24), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  /// Builds the wide buttons ("Score" and "Apprenticeships")
  Widget _buildWideButton(BuildContext context, String text) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shadowColor: Colors.lightBlueAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        // You might want to make these clickable too
        onTap: () {
          if (text == "Score & Rank Calculator / Result") {
            Navigator.pushNamed(context, AppRoutes.scoreResults);
          } else if (text == "Apprenticeships") {
            Navigator.pushNamed(context, AppRoutes.apprenticeships);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ),
    );
  }

  /// Builds a single item for the grid
  /// Builds a single item for the grid
  Widget _buildGridItem(BuildContext context, String text) {
    // --- THIS IS THE NEW LOGIC ---
    // We check if the text contains a space.
    // This tells us if it's a multi-word string.
    final bool hasSpaces = text.contains(' ');
    // --- END OF NEW LOGIC ---

    return InkWell(
      onTap: () {
        _onGridItemTapped(context, text);
      },
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shadowColor: Colors.lightBlueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // 1. We still use FittedBox to scale the result
            child: Text(
              text,
              textAlign: TextAlign.center,
              // 2. We set softWrap based on our new logic
              softWrap: hasSpaces, // <-- THE KEY CHANGE
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  /// 4. NEW: A central place to handle all grid item taps
  Widget _buildGridMenu(BuildContext context) {
    final List<String> menuItems = [
      "Course selection",
      "Live Lectures",
      "Time Table",
      "Scholarship",
      "Weekly Test",
      "Syllabus/ Modules",
      "PDF Notes",
      "Demo Class",
      "Assignments",
      "Attendance",
      "Quizzes",
      "Manage Resumes",
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        // Pass the item text to the build method
        return _buildGridItem(context, menuItems[index]);
      },
    );
  }

  void _onGridItemTapped(BuildContext context, String text) {
    // Example of how to handle different actions using a switch:
    switch (text) {
      case "Course selection":
        // Assuming you have a CourseSelectionScreen
        Navigator.pushNamed(context, AppRoutes.courseSelection);
        // Placeholder
        break;
      case "Live Lectures":
        // From our previous code
        Navigator.pushNamed(context, AppRoutes.liveLectures);
        break;
      case "Time Table":
        // From our previous code
        Navigator.pushNamed(context, AppRoutes.timeTable);
        break;
      case "Scholarship":
        Navigator.pushNamed(context, AppRoutes.scholarship);
        break;
      case "Weekly Test":
        // From our previous code
        Navigator.pushNamed(context, AppRoutes.weeklyTest);
        break;
      case "Syllabus/ Modules":
        Navigator.pushNamed(context, AppRoutes.syllabusModule);
        break;
      case "PDF Notes":
        // From our previous code
        Navigator.pushNamed(context, AppRoutes.pdfNotes);
        break;
      case "Demo Class":
        Navigator.pushNamed(context, AppRoutes.demoClass);
        break;
      case "Assignments":
        Navigator.pushNamed(context, AppRoutes.assignments);
        break;
      case "Attendance":
        Navigator.pushNamed(context, AppRoutes.attendance);
        break;
      case "Quizzes":
        Navigator.pushNamed(context, AppRoutes.quizzes);
        break;
      case "Manage Resumes":
        Navigator.pushNamed(context, AppRoutes.manageResumes);
        break;
    }
  }
}
