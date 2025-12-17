import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_routes.dart';
import '../../services/instructor_service.dart';

// 1. Change StatefulWidget -> ConsumerStatefulWidget
class InstructorDashboard extends ConsumerStatefulWidget {
  const InstructorDashboard({super.key});

  @override
  ConsumerState<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends ConsumerState<InstructorDashboard> {
  List<dynamic> _schedule = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // We can call the API immediately
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      // 2. Use ref.read to get the service
      final service = ref.read(instructorServiceProvider);
      final response = await service.getInstructorSchedule();

      if (mounted) {
        if (response['success'] == true) {
          setState(() {
            _schedule = response['schedule'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Failed to load schedule.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoLive(String scheduleId, String defaultTopic) async {
    final TextEditingController topicController = TextEditingController(text: defaultTopic);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Start Live Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Confirm the topic for this session:"),
            const SizedBox(height: 10),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., Algebra Basics"
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _startClassApi(scheduleId, topicController.text);
            },
            child: const Text("GO LIVE NOW", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _startClassApi(String scheduleId, String topic) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator())
    );

    try {
      // 3. Use ref.read to get the service
      final service = ref.read(instructorServiceProvider);
      final response = await service.startLiveClass(
          scheduleId: scheduleId,
          topic: topic
      );

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      // NEW CODE (Centralized Route)
      if (response['success'] == true) {
        final roomId = response['roomId'];
        final token = response['token'];

        if (!mounted) return;

        // Navigate using the route name and pass the arguments object
        Navigator.pushNamed(
          context,
          AppRoutes.liveClass,
          arguments: LiveClassArgs(
            roomId: roomId,
            token: token,
            isInstructor: true,
            displayName: "Instructor", // You can replace this with the real user name later
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Instructor Dashboard")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : _schedule.isEmpty
          ? const Center(child: Text("No classes scheduled for today!"))
          : RefreshIndicator(
        onRefresh: _fetchSchedule,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _schedule.length,
          itemBuilder: (context, index) {
            final slot = _schedule[index];
            // Access data safely
            final courseData = slot['course'] ?? {};
            final moduleData = slot['module'] ?? {};

            final courseTitle = courseData['title'] ?? 'Unknown Course';
            final subject = moduleData['title'] ?? 'General Session';
            final time = "${slot['start_time']} - ${slot['end_time']}";
            final scheduleId = slot['schedule_id'].toString();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const Chip(
                          label: Text("Scheduled", style: TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(courseTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Subject: $subject", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleGoLive(scheduleId, subject),
                        icon: const Icon(Icons.videocam),
                        label: const Text("Start Live Class"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}