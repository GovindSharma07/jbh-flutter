import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../app_routes.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color
    Color primaryColor = Theme.of(context).primaryColor ;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Use your common app bar
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- My Courses Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    MyCourseCard(
                      title: 'Python for Begineers',
                      purchaseDate: 'Purchased on 12 oct 2025',
                      statusIcon: const Icon(Icons.check_circle, color: Colors.green),
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    MyCourseCard(
                      title: 'Full Stack Development',
                      purchaseDate: 'Purchased on 06 oct 2024',
                      statusIcon: const Icon(Icons.watch_later_outlined, color: Colors.grey),
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Available Courses Section ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Available courses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Horizontal list
              SizedBox(
                height: 180, // Define a fixed height for the horizontal list
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // Add padding to the left and right of the list
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  children: [
                    AvailableCourseCard(
                      title: 'Web Development',
                      instructor: 'Mr. Ashish Singh',
                      timeLine: 'Time line: 10 weeks',
                      primaryColor: primaryColor,
                    ),
                    AvailableCourseCard(
                      title: 'Web Development',
                      instructor: 'Mr. Ashish Singh',
                      timeLine: 'Time line: 10 weeks',
                      primaryColor: primaryColor,
                    ),
                    AvailableCourseCard(
                      title: 'Web Development',
                      instructor: 'Mr. Ashish Singh',
                      timeLine: 'Time line: 10 weeks',
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Use your nav bar, setting this as index 1
      bottomNavigationBar: FloatingCustomNavBar(currentIndex: 1),
    );
  }
}

// --- Reusable Card for "My Courses" ---
class MyCourseCard extends StatelessWidget {
  final String title;
  final String purchaseDate;
  final Icon statusIcon;
  final Color primaryColor;

  const MyCourseCard({
    Key? key,
    required this.title,
    required this.purchaseDate,
    required this.statusIcon,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Column: Text
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
                  purchaseDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Column: Icon & Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              statusIcon,
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Go To Course'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Reusable Card for "Available Courses" ---
class AvailableCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String timeLine;
  final Color primaryColor;

  const AvailableCourseCard({
    Key? key,
    required this.title,
    required this.instructor,
    required this.timeLine,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use SizedBox to give the card a fixed width
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Add margin to space out cards in the list
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                instructor,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                timeLine,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(), // Pushes button to the bottom
              ElevatedButton(
                onPressed: () {
                  // When "Buy Now" is tapped, go to Payment Options
                  Navigator.pushNamed(context, AppRoutes.paymentOptions);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 36), // Full width
                ),
                child: const Text('Buy Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}