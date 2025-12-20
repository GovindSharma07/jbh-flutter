import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Components/upcoming_lecture_card.dart';
import 'package:jbh_academy/services/student_service.dart';

import '../Components/live_lecture_card.dart';
import '../app_routes.dart';

class LecturesScreen extends ConsumerStatefulWidget {
  const LecturesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends ConsumerState<LecturesScreen> {
  List<dynamic> _todaySchedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLectures();
  }

  Future<void> _fetchLectures() async {
    try {
      // Fetch today's schedule from the backend
      final schedule = await ref
          .read(studentServiceProvider)
          .getTodaySchedule();
      if (mounted) {
        setState(() {
          _todaySchedule = schedule;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- THE LOGIC YOU PROVIDED (Integrated Here) ---
  void _onJoinClassPressed(int liveLectureId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Call Backend (Marks Attendance & Gets Token)
      final data = await ref
          .read(studentServiceProvider)
          .joinLiveLecture(liveLectureId);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      final String token = data['token'];
      final String roomId = data['roomId'];

      // 2. Navigate to the actual Video Screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.liveClass,
          arguments: LiveClassArgs(
            roomId: roomId,
            token: token,
            displayName: "Student",
          ),
        );
      }
    } catch (e) {
      // Close loading dialog on error
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error joining: $e")));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme
        .of(context)
        .primaryColor;

    // 2. Filter Logic
    // "Live" means it has a live_lecture_id OR is_live_now is true
    final liveNow = _todaySchedule.where((s) {
      return s['live_lecture_id'] != null || s['is_live_now'] == true;
    }).toList();

    // "Upcoming" is everything else
    final upcoming = _todaySchedule.where((s) {
      return s['live_lecture_id'] == null && s['is_live_now'] != true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchLectures,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION A: LIVE CLASSES ---
                if (liveNow.isNotEmpty) ...[
                  Text('Live Now', style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
                  const SizedBox(height: 10),

                  // Render the Clickable Cards
                  ...liveNow.map((slot) {
                    return LiveLectureCard(
                      primaryColor: primaryColor,
                      title: slot['course']['title'] ?? 'Live Class',
                      instructor: slot['instructor']['full_name'] ??
                          'Instructor',
                      onJoin: () {
                        // 3. Handle the Click
                        final liveId = slot['live_lecture_id'];
                        if (liveId != null) {
                          _onJoinClassPressed(liveId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Error: Missing Live ID")),
                          );
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],

                // --- SECTION B: UPCOMING CLASSES ---
                const Text('Upcoming Schedule', style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                if (upcoming.isEmpty && liveNow.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20),
                      child: Text("No classes today"))),

                // Render the Standard Cards
                ...upcoming.map((slot) {
                  return UpcomingLectureCard(
                    imagePath: 'assets/images/lecture_image.png',
                    title: slot['course']['title'] ?? 'Class',
                    date: "Today",
                    time: "${slot['start_time']} - ${slot['end_time']}",
                    instructor: slot['instructor']['full_name'] ?? 'Instructor',
                    reminderTime: 'Scheduled',
                    primaryColor: primaryColor,
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}

