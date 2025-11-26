import 'package:flutter/material.dart';
import 'package:jbh_academy/Pages/weekly_test/test_card.dart';

class UpcomingTab extends StatelessWidget {
  final Color primaryColor;
  const UpcomingTab({Key? key, required this.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TestCard(
          title: 'Dot. Net',
          imagePath: 'assets/ai_icon.png', // Replace with your asset
          primaryColor: primaryColor,
          details: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('10:00AM', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('Date: 12OCT-2025', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          action: null,
        ),
        const SizedBox(height: 16),
        TestCard(
          title: 'React js',
          imagePath: 'assets/ai_icon.png', // Replace with your asset
          primaryColor: primaryColor,
          details: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('10:00AM', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('Date: 13OCT-2025', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          action: null,
        ),
      ],
    );
  }
}