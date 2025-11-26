import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../Components/upcoming_lecture_card.dart';

class LecturesScreen extends StatelessWidget {
  const LecturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a primary color for consistency
    final primaryColor = Theme.of(context).primaryColor; // A dark blue for buttons/accents

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Lectures Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Lectures',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black54),
                    onPressed: () {
                      // Handle filter
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Live Lecture Card
              LiveLectureCard(primaryColor: primaryColor),
              const SizedBox(height: 30),

              // Upcoming Lectures Section
              const Text(
                'Upcoming Lectures',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Upcoming Lecture Cards (using a list for multiple entries)
              UpcomingLectureCard(
                imagePath: 'assets/images/lecture_image.png', // Replace with actual asset path
                title: 'Python Lecture 1',
                date: '15 Oct, 2025',
                time: '10:00 am - 1:00 pm',
                instructor: 'Mr. Mohit Lochab',
                reminderTime: 'Start In 2 hours',
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              UpcomingLectureCard(
                imagePath: 'assets/images/lecture_image.png', // Replace with actual asset path
                title: 'Python Lecture 2',
                date: '16 Oct, 2025',
                time: '10:00 am - 1:00 pm',
                instructor: 'Mr. Mohit Lochab',
                reminderTime: 'Start In 1 day',
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              // Add more UpcomingLectureCard widgets as needed
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}

// Widget for the Live Lecture Card
class LiveLectureCard extends StatelessWidget {
  final Color primaryColor;

  const LiveLectureCard({Key? key, required this.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/lecture_image.png', // Replace with your live teacher image asset
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● Live Now',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Python Numpy - pandas class',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'By Mr. Ashish Singh',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '10:00 am - 12:00pm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Join Now
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Dark blue button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
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

