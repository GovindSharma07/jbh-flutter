import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../Components/common_app_bar.dart';
import '../Components/time_table_card.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color for buttons and navigation
    final Color primaryColor =  Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Time Table',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              TimeTableCard(
                title: 'Python time table',
                // Make sure to add this image to your assets
                imagePath: 'assets/images/lecture_image.png',
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              TimeTableCard(
                title: 'Artificial Intelligence',
                // Make sure to add this image to your assets
                imagePath: 'assets/images/lecture_image.png',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:FloatingCustomNavBar(),
    );
  }
}
