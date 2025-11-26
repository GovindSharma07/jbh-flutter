import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../../Components/common_app_bar.dart';
import '../../app_routes.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final title = args['title'];
    final price = args['price'];

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCourseCard(title: title, price: price),
            _buildCourseInformation(context),
            // This Sized-Box adds padding at the bottom of the scrollable
            // content so it doesn't get hidden by the pay button AND nav bar.
            const SizedBox(height: 180),
            _buildFloatingPayButton(context),
          ],
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  /// Builds the top card with course title and price
  Widget _buildTopCourseCard({required String title, required String price}) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Light card color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline, // Question mark icon
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title course', // Added "course" as per the image
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price : $price',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const Text(
                  'Description:',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Course Information" section
  Widget _buildCourseInformation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Course', 'Python for Beginners'),
          const SizedBox(height: 12),
          _buildInfoRow('Course Price', '₹999'),
        ],
      ),
    );
  }

  /// Helper for building a two-column info row
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the floating "PAY NOW" button
  Widget _buildFloatingPayButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        // This padding places it just above the nav bar
        padding: const EdgeInsets.only(bottom: 100.0, left: 16, right: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
                AppRoutes.paymentOptions,
            );
          },
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'PAY ₹849 NOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF0C1321,
            ), // Same dark color as nav bar
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blueAccent[100]!, width: 1),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}
