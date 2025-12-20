import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:table_calendar/table_calendar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import '../Components/common_app_bar.dart';
import '../services/student_service.dart'; // Import StudentService

// 1. Change to ConsumerStatefulWidget
class AttendanceScreen extends ConsumerStatefulWidget {
  static const String routeName = '/attendance';

  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  Map<DateTime, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Call fetch after the first frame to safely use 'ref'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAttendance();
    });
  }

  Future<void> _fetchAttendance() async {
    try {
      // 2. Use ref.read to get the service
      final records = await ref.read(studentServiceProvider).getAttendance();

      final Map<DateTime, String> parsedData = {};

      for (var record in records) {
        DateTime date = DateTime.parse(record['date']).toLocal();
        // Normalize to UTC Midnight for TableCalendar
        DateTime dateKey = DateTime.utc(date.year, date.month, date.day);
        parsedData[dateKey] = record['status'];
      }

      if (mounted) {
        setState(() {
          _attendanceStatus = parsedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching attendance: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Stats getters
  int get _presentDays => _attendanceStatus.values.where((s) => s == 'present').length;
  int get _absentDays => _attendanceStatus.values.where((s) => s == 'absent').length;
  int get _totalDays => _presentDays + _absentDays;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching
    if (_isLoading) {
      return Scaffold(
        appBar: buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const FloatingCustomNavBar(),
      );
    }

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Attendance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildInfoCard(context, title: 'Total', value: '$_totalDays', color: Colors.blueAccent)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInfoCard(context, title: 'Present', value: '$_presentDays', color: Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInfoCard(context, title: 'Absent', value: '$_absentDays', color: Colors.redAccent)),
                ],
              ),

              const SizedBox(height: 24),

              // Calendar
              _buildAttendanceCalendar(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FloatingCustomNavBar(),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required Color color}) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shadowColor: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

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
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.black),
            weekendTextStyle: const TextStyle(color: Colors.black),
            todayDecoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
            todayTextStyle: const TextStyle(color: Colors.blueAccent),
            selectedDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: Colors.white),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final dateKey = DateTime.utc(day.year, day.month, day.day);
              final status = _attendanceStatus[dateKey];
              if (status != null) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: status == 'present' ? Colors.green : Colors.redAccent,
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