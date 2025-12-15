import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../../app_routes.dart';

class ApprenticeshipDetailScreen extends StatelessWidget {
  const ApprenticeshipDetailScreen({super.key});

  // Helper function to build the detail rows
  Widget _buildDetailRow(String title, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: primaryColor)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final int apprenticeshipId = args['id'];
    final String title = args['title'];
    final String imagePath = args['imagePath'];
    final String description = args['description'];
    final String duration = args['duration'];
    final String location = args['location'];

    // 2. Get the Applied Status (Default to false if null)
    final bool hasApplied = args['hasApplied'] ?? false;

    // Define the primary color
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Image ---
                Image.network(
                  imagePath,
                  // This contains the URL passed from the previous screen
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),

                // --- Content Padding ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // Use variable
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'About The Apprenticeship :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description, // Use variable
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Detail Rows ---
                      _buildDetailRow('Duration', duration, primaryColor),
                      // Use variable
                      _buildDetailRow('Location', location, primaryColor),

                      // Use variable
                      const SizedBox(height: 24),

                      // --- Apply Button ---
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: hasApplied
                                ? null // Disable button (null onPressed)
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.applyApprenticeship,
                                      arguments: {'id': apprenticeshipId, 'title': title},
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              // Change color: Grey if applied, Primary if not
                              backgroundColor: hasApplied
                                  ? Colors.grey
                                  : primaryColor,
                              disabledBackgroundColor: Colors.grey.withOpacity(
                                0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              hasApplied ? 'Already Applied' : 'Apply Now',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}
