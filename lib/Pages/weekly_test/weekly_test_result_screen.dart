import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Pages/weekly_test/result_card.dart';

class WeeklyTestResultScreen extends StatelessWidget {
  const WeeklyTestResultScreen({
    super.key,
  });

  // Set the default selected tab to "Result"
  final Color primaryColor = const Color(0xFF003B5C);

  final Color cardBackgroundColor = const Color(0xFFA9BCCA);



  // Greyish-blue card
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String title = args['title'];

    final String score = args['score'];

    final String performance = args['performance'];

    final double percentage = args['percentage'];
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: SizedBox(
        height: MediaQuery.of(context).size.width*0.75,
        child: ResultCard(
          title: title,
          score: score,
          performance: performance,
          percentage: percentage,
          cardBackgroundColor: cardBackgroundColor,
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}
