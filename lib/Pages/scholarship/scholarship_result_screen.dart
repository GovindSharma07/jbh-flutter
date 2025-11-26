import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

class ScholarshipResultsScreen extends StatelessWidget {
  const ScholarshipResultsScreen({Key? key}) : super(key: key);

  // Helper widget for the result card
  Widget _buildResultCard({
    required String title,
    required String score,
    required String rank,
    required String eligibility,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Dark blue color
        borderRadius: BorderRadius.circular(16.0),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: $score | Rank: $rank',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eligibility,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Right Column: Arrow Icon
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Text(
                  'Scholarship results',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildResultCard(
                title: 'Python Django Test',
                score: '100/90',
                // From image
                rank: '12/200',
                eligibility: 'Eligible for Scholarship',
                context: context,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Dot. Net',
                score: '100/90',
                rank: '12/200',
                eligibility: 'Eligible for Scholarship',
                context: context,
              ),
              // Add more cards here
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}
