import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

// --- Imports from your project ---
import 'package:jbh_academy/state/auth_notifier.dart';
import 'package:jbh_academy/services/instructor_service.dart';
import 'package:jbh_academy/app_routes.dart';
import 'package:jbh_academy/Pages/live_class/live_class_screen.dart';

// --- Import Refactored Widgets ---
import 'widgets/class_card.dart';
import 'widgets/course_card.dart';
import 'widgets/stat_badge.dart';
import '../../Components/empty_state_widget.dart';

// Provider to fetch dashboard data
final instructorDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(instructorServiceProvider).getDashboardData();
});

class InstructorDashboard extends ConsumerWidget {
  const InstructorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final dashboardAsync = ref.watch(instructorDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading dashboard: $err')),
        data: (data) {
          final todayClasses = data['todaySchedule'] as List;
          final courses = data['courses'] as List;
          final special = data['upcomingSpecial'] as List;

          return CustomScrollView(
            slivers: [
              // 1. Header Section
              _buildSliverAppBar(context, ref, user?.fullName ?? "Instructor", todayClasses.length, courses.length),

              // 2. Today's Classes Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      todayClasses.isEmpty
                          ? const EmptyStateWidget(
                        message: "No classes scheduled for today.\nEnjoy your day off!",
                        icon: Icons.event_available,
                      )
                          : SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todayClasses.length,
                          itemBuilder: (context, index) {
                            final cls = todayClasses[index];
                            return _ClassCardWrapper(
                                cls: cls,
                                ref: ref,
                                userName: user?.fullName ?? "Instructor"
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. My Courses Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Courses",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),

              courses.isEmpty
                  ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: EmptyStateWidget(message: "You haven't been assigned any courses yet."),
                  )
              )
                  : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => CourseCard(course: courses[index]),
                    childCount: courses.length,
                  ),
                ),
              ),

              // 4. Upcoming Special Lectures
              if (special.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Upcoming Special Lectures",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...special.map((s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: const Icon(Icons.star, color: Colors.orange),
                          ),
                          title: Text(s['course']['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(s['specific_date']))),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                            child: Text("${s['start_time']} - ${s['end_time']}", style: const TextStyle(fontSize: 12)),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  // --- UPDATED LOGOUT LOGIC HERE ---
  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, String name, int classCount, int courseCount) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  StatBadge(text: "$classCount Classes Today", icon: Icons.calendar_today),
                  const SizedBox(width: 10),
                  StatBadge(text: "$courseCount Courses", icon: Icons.book),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            // 1. Perform the logout logic
            await ref.read(authNotifierProvider.notifier).logout();

            // 2. Check if context is valid before navigating
            if (context.mounted) {
              // 3. Clear stack and go to Login
              // Ensure '/login' matches the route name defined in your app_routes.dart or main.dart
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
        )
      ],
    );
  }
}

// ... [The _ClassCardWrapper remains unchanged] ...
class _ClassCardWrapper extends StatelessWidget {
  final dynamic cls;
  final WidgetRef ref;
  final String userName;

  const _ClassCardWrapper({
    required this.cls,
    required this.ref,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLive = true;

    return ClassCard(
      title: cls['course']['title'],
      startTime: cls['start_time'],
      endTime: cls['end_time'],
      isLive: isLive,
      onStart: () => _handleGoLive(context),
    );
  }

  Future<void> _handleGoLive(BuildContext context) async {
    final mic = await Permission.microphone.request();
    final cam = await Permission.camera.request();

    if (mic != PermissionStatus.granted || cam != PermissionStatus.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera and Microphone permissions are required to go live.")),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    try {
      final scheduleId = cls['schedule_id'];
      final title = cls['course']['title'] ?? "Live Class";

      final result = await ref.read(instructorServiceProvider).startLiveClass(
        scheduleId: scheduleId,
        topic: title,
      );

      if (context.mounted) {
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveClassScreen(
              roomId: result['roomId'],
              token: result['token'],
              isInstructor: true,
              displayName: userName,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to go live: $e"),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }
}