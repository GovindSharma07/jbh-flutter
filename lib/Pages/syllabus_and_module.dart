import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Models/course_model.dart';

import '../Components/common_app_bar.dart';
import '../services/course_service.dart';
import 'course/lesson_viewer_screen.dart'; // Ensure you have getCourseDetail in CourseService too

// You need to duplicate the provider logic or share it.
// Assuming you added getCourseDetail to CourseService as well:
final studentCourseDetailProvider = FutureProvider.family
    .autoDispose<Course, int>((ref, courseId) async {
      // Use CourseService here, not AdminService
      return ref.watch(courseServiceProvider).getCourseDetail(courseId);
    });

class SyllabusModulesScreen extends ConsumerWidget {
  const SyllabusModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Course || args.courseId == null) {
      return const Scaffold(body: Center(child: Text("Error: No course data")));
    }

    final courseId = args.courseId!;
    final detailAsync = ref.watch(studentCourseDetailProvider(courseId));

    return Scaffold(
      appBar: buildAppBar(context, title: args.title),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (course) {
          final modules = course.modules ?? [];
          if (modules.isEmpty)
            return const Center(child: Text("No content available yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    module.title,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: module.lessons.map((lesson) {
                    return ListTile(
                      leading: Icon(
                        lesson.contentType == 'pdf'
                            ? Icons.picture_as_pdf
                            : Icons.play_circle_fill,
                        color: lesson.contentType == 'pdf'
                            ? Colors.red
                            : Colors.blue, // Explicit Colors
                        size: 30,
                      ),
                      title: Text(lesson.title),
                      trailing: lesson.isFree
                          ? const Chip(
                              label: Text(
                                "Demo",
                                style: TextStyle(fontSize: 10),
                              ),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to the Lesson Viewer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LessonViewerScreen(lesson: lesson),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: FloatingCustomNavBar(),
    );
  }
}
