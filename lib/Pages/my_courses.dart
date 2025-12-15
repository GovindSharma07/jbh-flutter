import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Components/common_app_bar.dart';
import '../Components/floating_custom_nav_bar.dart';
import '../services/course_service.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCoursesAsync = ref.watch(myCoursesProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: "My Courses"),
      body: myCoursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text("You haven't enrolled in any courses yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to Lessons/Syllabus screen (To be built next)
                    // Navigator.pushNamed(context, AppRoutes.syllabusModule, arguments: course);
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: FloatingCustomNavBar(currentIndex: 1),
    );
  }
}