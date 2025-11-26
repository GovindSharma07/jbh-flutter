import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Pages/weekly_test/result_tab.dart';
import 'package:jbh_academy/Pages/weekly_test/today_tab.dart';
import 'package:jbh_academy/Pages/weekly_test/upcoming_tab.dart';

class WeeklyTestScreen extends StatefulWidget {
  const WeeklyTestScreen({super.key});

  @override
  State<WeeklyTestScreen> createState() => _WeeklyTestScreenState();
}

class _WeeklyTestScreenState extends State<WeeklyTestScreen> {
  // 0 = Today, 1 = Upcoming, 2 = Result
  int _selectedTabIndex = 0;

  // Define the primary color


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16,16,16,0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weekly Test',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          // Custom Tab Button Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildTabButton(context, 'Today', 0),
                const SizedBox(width: 12),
                _buildTabButton(context, 'Upcoming', 1),
                const SizedBox(width: 12),
                _buildTabButton(context, 'Result', 2),
              ],
            ),
          ),

          // Conditional Tab Content
          Expanded(child: _buildTabContent(primaryColor)),
        ],
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  // Helper widget to build the tab buttons
  Widget _buildTabButton(BuildContext context, String title, int index) {

    final Color primaryColor = Theme.of(context).primaryColor;
    final bool isSelected = (_selectedTabIndex == index);

    return Expanded(
      child: isSelected
          ? ElevatedButton(
              onPressed: () {
                setState(() => _selectedTabIndex = index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: () {
                setState(() => _selectedTabIndex = index);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  // Helper widget to show the correct content
  Widget _buildTabContent(primaryColor) {
    switch (_selectedTabIndex) {
      case 0:
        return TodayTab(primaryColor: primaryColor);
      case 1:
        return UpcomingTab(primaryColor: primaryColor);
      case 2:
        return ResultTab(primaryColor: primaryColor);
      default:
        return TodayTab(primaryColor: primaryColor);
    }
  }
}
