import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Pages/syllabus_and_module.dart';
import '../Components/common_app_bar.dart';
import '../Components/floating_custom_nav_bar.dart';
import '../app_routes.dart';
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
                  subtitle: course.enrollmentDate != null
                      ? Text("Enrolled on: ${course.enrollmentDate!.toLocal().toString().split(' ')[0]}")
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.green, size: 20),
                  ),
                  onTap: () {
                    // Navigate to Syllabus Screen passing the Course object
                    Navigator.pushNamed(
                        context,
                        AppRoutes.syllabusModule,
                        arguments: SyllabusScreenArgs(
                          courseId: course.courseId!,
                          title: course.title,
                          isEnrolled: true,
                        ),
                    );
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