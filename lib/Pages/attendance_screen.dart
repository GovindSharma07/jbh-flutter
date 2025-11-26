import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Components/common_app_bar.dart';

class AttendanceScreen extends StatefulWidget {
  // Define a routeName for main.dart
  static const String routeName = '/attendance';

  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // --- Mock Data ---
  // In a real app, you'd fetch this.
  // We use this to mark days on the calendar.
  final Map<DateTime, String> _attendanceStatus = {
    DateTime.utc(2025, 11, 1): 'present',
    DateTime.utc(2025, 11, 3): 'present',
    DateTime.utc(2025, 11, 4): 'absent',
    DateTime.utc(2025, 11, 5): 'present',
    DateTime.utc(2025, 11, 6): 'present',
    DateTime.utc(2025, 11, 10): 'present',
    DateTime.utc(2025, 11, 11): 'present',
    DateTime.utc(2025, 11, 12): 'absent',
  };

  // Stats derived from the data
  int get _presentDays => _attendanceStatus.values
      .where((status) => status == 'present')
      .length;
  int get _absentDays => _attendanceStatus.values
      .where((status) => status == 'absent')
      .length;
  int get _totalDays => _presentDays + _absentDays;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Screen Title
              Text(
                'Attendance',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),
              // --- Summary Cards ---
              _buildSummaryCards(),
              const SizedBox(height: 24),
              // --- Calendar ---
              _buildAttendanceCalendar(),
              const SizedBox(height: 120), // Padding for the nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }

  /// Builds the 3 summary cards for Total, Present, Absent
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            title: 'Total Days',
            value: _totalDays.toString(),
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            title: 'Present',
            value: _presentDays.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            title: 'Absent',
            value: _absentDays.toString(),
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  /// Helper for a single summary card
  Widget _buildInfoCard(BuildContext context,
      {required String title, required String value, required Color color}) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shadowColor: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the interactive TableCalendar
  Widget _buildAttendanceCalendar() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2026, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // update `_focusedDay` here as well
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          // --- Custom Styling ---
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle:
            const TextStyle(color: Colors.black, fontSize: 18),
            leftChevronIcon:
            const Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon:
            const Icon(Icons.chevron_right, color: Colors.black),
          ),
          calendarStyle: CalendarStyle(
            // Use black for most text
            defaultTextStyle: const TextStyle(color: Colors.black),
            weekendTextStyle: const TextStyle(color: Colors.black),
            outsideTextStyle: const TextStyle(color: Colors.grey),

            // Style for "Today"
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: Colors.blueAccent),

            // Style for "Selected Day"
            selectedDecoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(color: Colors.white),
          ),
          // --- Event Markers ---
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final status = _attendanceStatus[DateTime.utc(day.year, day.month, day.day)];
              if (status != null) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: status == 'present'
                          ? Colors.green
                          : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}