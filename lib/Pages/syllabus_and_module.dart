import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../Components/common_app_bar.dart';

class SyllabusModulesScreen extends StatelessWidget {
  // Define a routeName for main.dart
  static const String routeName = '/syllabus_modules';

  const SyllabusModulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme
        .of(context)
        .primaryColor;

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Screen Title
              Text(
                'Syllabus & Modules',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontSize: 22,
                  color: primaryColor,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),

              // Module Cards
              _buildModuleCard(
                context: context,
                title: 'Python Django',
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              _buildModuleCard(
                context: context,
                title: 'Cyber Security',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  /// Helper widget to build a single module card
  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required Color primaryColor, // Your new parameter
  }) {
    return Card(
      color: Theme
          .of(context)
          .cardColor,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Title
            Text(
              title,
              style: TextStyle(
                color: primaryColor, // Use the primary color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // --- Improved "View Syllabus" Button ---

            // 3. ClipRRect ensures the InkWell ripple matches the border
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                // 4. Add the onTap functionality
                onTap: () {
                  print('View Syllabus for $title');
                  // Add your navigation logic here
                },
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // 5. Use Center for perfect text alignment
                  child: const Center(
                    child: Text(
                      "View Syllabus",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // --- End of Improved Button ---
          ],
        ),
      ),
    );
  }
}
