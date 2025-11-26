import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../../app_routes.dart';
// Import the detail screen you just created

class ApprenticeshipsScreen extends StatelessWidget {
  const ApprenticeshipsScreen({Key? key}) : super(key: key);

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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Apprenticeship',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ApprenticeshipCard(
                title: 'Junior Tech Developer',
                company: 'Tech Solutions',
                imagePath: 'assets/tech_solutions.png',
                // Add the onTap callback
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.apprenticeshipDetail,
                    arguments: {
                      'title': 'Junior Tech Developer',
                      'company': 'Tech Solutions',
                      "imagePath": 'assets/web_dev.png',
                      "description":
                          'Learn to build modern, responsive web applications from scratch.',
                      "duration": '6 Months',
                      "location": 'On-Site',
                    },
                  );
                },
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              ApprenticeshipCard(
                title: 'Web Developer Intern',
                company: 'Building Co.',
                imagePath: 'assets/web_dev.png',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.apprenticeshipDetail,
                    arguments: {
                      'title': 'Web Developer Intern',
                      'company': 'Build Co.',
                      "imagePath": 'assets/web_dev.png',
                      "description":
                          'Learn to build modern, responsive web applications from scratch.',
                      "duration": '6 Months',
                      "location": 'On-Site',
                    },
                  );
                },
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              ApprenticeshipCard(
                title: 'Graphics Designer',
                company: 'Nokia',
                imagePath: 'assets/nokia.png',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.apprenticeshipDetail,
                    arguments: {
                      'title': 'Web Developer Intern',
                      'company': 'Build Co.',
                      "imagePath": 'assets/web_dev.png',
                      "description":
                          'Learn to build modern, responsive web applications from scratch.',
                      "duration": '6 Months',
                      "location": 'On-Site',
                    },
                  );
                },
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              ApprenticeshipCard(
                title: 'Data Analyst',
                company: 'Global Analytics',
                imagePath: 'assets/data_analyst.png',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.apprenticeshipDetail,
                    arguments: {
                      'title': 'Web Developer Intern',
                      'company': 'Build Co.',
                      "imagePath": 'assets/web_dev.png',
                      "description":
                          'Learn to build modern, responsive web applications from scratch.',
                      "duration": '6 Months',
                      "location": 'On-Site',
                    },
                  );
                },
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}

// --- Reusable Apprenticeship Card Widget (FIXED) ---
class ApprenticeshipCard extends StatelessWidget {
  final String title;
  final String company;
  final String imagePath;
  final VoidCallback onTap; // <-- Was missing in your instance, but in class
  final Color color;

  const ApprenticeshipCard({
    Key? key,
    required this.title,
    required this.company,
    required this.imagePath,
    required this.onTap,
    required this.color, // <-- Make sure to pass this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap, // <-- Use the onTap property from the constructor
        child: Row(
          children: [
            // --- Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                // Error builder for placeholder
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: color,
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // --- Text Content ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
