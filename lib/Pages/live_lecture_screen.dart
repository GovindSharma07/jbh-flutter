import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Components/upcoming_lecture_card.dart';
import 'package:jbh_academy/services/student_service.dart';

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
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Filter Logic:
    // We assume the backend returns a field 'is_live' or checks if 'live_lecture_id' is present
    final liveNow = _todaySchedule
        .where((s) => s['live_lecture_id'] != null || s['status'] == 'live')
        .toList();
    final upcoming = _todaySchedule
        .where((s) => s['live_lecture_id'] == null && s['status'] != 'live')
        .toList();

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
                      // --- LIVE NOW SECTION ---
                      if (liveNow.isNotEmpty) ...[
                        Text(
                          'Live Lectures',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...liveNow.map((slot) {
                          // Extract Data
                          final title = slot['course']['title'] ?? 'Live Class';
                          final instructor =
                              slot['instructor']['full_name'] ?? 'Instructor';
                          final liveLectureId =
                              slot['live_lecture_id']; // Needed for Joining

                          return LiveLectureCard(
                            primaryColor: primaryColor,
                            title: title,
                            instructor: instructor,
                            onJoin: () {
                              if (liveLectureId != null) {
                                _onJoinClassPressed(liveLectureId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Class hasn't started yet!"),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 30),
                      ],

                      // --- UPCOMING SECTION ---
                      const Text(
                        'Upcoming Lectures',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (upcoming.isEmpty && liveNow.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text("No lectures scheduled for today."),
                          ),
                        ),

                      ...upcoming.map((slot) {
                        final title = slot['course']['title'] ?? 'Class';
                        final start = slot['start_time'] ?? '00:00';
                        final end = slot['end_time'] ?? '00:00';
                        final instructor =
                            slot['instructor']['full_name'] ?? 'Instructor';

                        return UpcomingLectureCard(
                          imagePath: 'assets/images/lecture_image.png',
                          title: title,
                          date: "Today",
                          time: '$start - $end',
                          instructor: instructor,
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

// Updated Card to accept dynamic data
class LiveLectureCard extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String instructor;
  final VoidCallback onJoin;

  const LiveLectureCard({
    Key? key,
    required this.primaryColor,
    required this.title,
    required this.instructor,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/lecture_image.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● Live Now',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By $instructor',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
