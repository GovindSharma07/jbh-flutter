import 'package:flutter/material.dart';
import 'package:jbh_academy/Pages/weekly_test/test_card.dart';

import '../../app_routes.dart';

class ResultTab extends StatelessWidget {
  final Color primaryColor;

  const ResultTab({Key? key, required this.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TestCard(
          title: 'Python Django',
          imagePath: 'assets/django_icon.png',
          // Replace with your asset
          primaryColor: primaryColor,
          details: const Text(
            'Date: 10 OCT-2025',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          action: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.weeklyTestResult,
                arguments: {
                  'title': 'Python Django',
                  'score': '20',
                  'performance': 'Good',
                  'percentage': 0.8,
                }

              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Show Result',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TestCard(
          title: 'Python Django',
          imagePath: 'assets/django_icon.png',
          // Replace with your asset
          primaryColor: primaryColor,
          details: const Text(
            'Date: 10 OCT-2025',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          action: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.weeklyTestResult,
                arguments: {
                  'title': 'Python Django',
                  'score': '20',
                  'performance': 'Good',
                  'percentage': 0.8,
                }
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Show Result',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
