import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import '../Components/common_app_bar.dart';
import '../services/student_service.dart';

class TimeTableScreen extends ConsumerStatefulWidget {
  static const String routeName = '/time-table';
  const TimeTableScreen({super.key});

  @override
  ConsumerState<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends ConsumerState<TimeTableScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;

  // 1. Weekly: Grouped by Course Name
  Map<String, List<dynamic>> _weeklySchedule = {};

  // 2. One-Time: Simple List
  List<dynamic> _upcomingClasses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    try {
      final rawSchedule = await ref.read(studentServiceProvider).getWeeklyTimetable();

      final Map<String, List<dynamic>> weeklyGrouped = {};
      final List<dynamic> oneTimeList = [];

      for (var slot in rawSchedule) {
        String type = slot['schedule_type'] ?? 'recurring';

        if (type == 'recurring') {
          // Group by Course Title
          String courseName = slot['course']['title'];
          if (!weeklyGrouped.containsKey(courseName)) {
            weeklyGrouped[courseName] = [];
          }
          weeklyGrouped[courseName]!.add(slot);
        } else {
          oneTimeList.add(slot);
        }
      }

      if (mounted) {
        setState(() {
          _weeklySchedule = weeklyGrouped;
          _upcomingClasses = oneTimeList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context, title: "Schedule"),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: "Weekly Schedule"),
                Tab(text: "Upcoming Classes"),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyView(),
                _buildUpcomingView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingCustomNavBar(),
    );
  }

  // --- TAB 1: WEEKLY RECURRING ---
  Widget _buildWeeklyView() {
    if (_weeklySchedule.isEmpty) {
      return const Center(child: Text("No weekly classes found."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _weeklySchedule.keys.map((courseName) {
        final slots = _weeklySchedule[courseName]!;
        // Sort slots by day priority (Optional optimization)
        return _buildCourseCard(courseName, slots);
      }).toList(),
    );
  }

  // --- TAB 2: ONE-TIME UPCOMING ---
  Widget _buildUpcomingView() {
    if (_upcomingClasses.isEmpty) {
      return const Center(child: Text("No upcoming extra classes."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingClasses.length,
      itemBuilder: (context, index) {
        final slot = _upcomingClasses[index];
        return _buildSingleClassCard(slot);
      },
    );
  }

  // --- WIDGET: Card for Weekly Grouped Classes ---
  Widget _buildCourseCard(String courseName, List<dynamic> slots) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Course Name
            Row(
              children: [
                Icon(Icons.book, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    courseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // SLOTS LIST
            ...slots.map((slot) {
              final String instructor = slot['instructor']?['full_name'] ?? 'Instructor';
              final String day = slot['day_of_week'] ?? 'Day';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Day Badge
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day.substring(0, 3), // Mon, Tue
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 2. Class Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIXED: Removed 'module.title' to avoid "N/A"
                          Text(
                              "${slot['start_time']} - ${slot['end_time']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16
                              )
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                instructor,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: Card for Single Upcoming Class ---
  Widget _buildSingleClassCard(dynamic slot) {
    String dateStr = "N/A";
    if (slot['specific_date'] != null) {
      DateTime date = DateTime.parse(slot['specific_date']);
      dateStr = DateFormat('MMM dd, yyyy').format(date);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.event_available, color: Colors.orange),
        ),
        // For one-time classes, use the Course Name as the main title
        title: Text(slot['course']['title'] ?? 'Extra Class'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Instructor: ${slot['instructor']?['full_name']}"),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("$dateStr  |  ${slot['start_time']}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}