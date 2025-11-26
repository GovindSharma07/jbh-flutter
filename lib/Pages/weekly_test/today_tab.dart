import 'package:flutter/material.dart';
import 'package:jbh_academy/Pages/weekly_test/test_card.dart';

class TodayTab extends StatelessWidget {
  final Color primaryColor;
  const TodayTab({Key? key, required this.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TestCard(
          title: 'Python MCQ',
          imagePath: 'assets/ai_icon.png', // Replace with your asset
          isLive: true,
          primaryColor: primaryColor,
          details: const Text(
            '10:00AM',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          action: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start Test', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TestCard(
          title: 'Computer Literacy',
          imagePath: 'assets/ai_icon.png', // Replace with your asset
          primaryColor: primaryColor,
          details: const Text(
            '10:00AM',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          action: null, // No action button for this one
        ),
      ],
    );
  }
}