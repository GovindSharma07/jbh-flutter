import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/floating_custom_nav_bar.dart';
import '../../Models/course_model.dart';
import '../../Components/common_app_bar.dart';
import '../../services/course_service.dart';
import 'course/lesson_viewer_screen.dart';

// 1. Define Arguments Class
class SyllabusScreenArgs {
  final int courseId;
  final String title;
  final bool isEnrolled;

  SyllabusScreenArgs({
    required this.courseId,
    required this.title,
    required this.isEnrolled,
  });
}

// Provider to fetch full details (Modules + Lessons)
final studentCourseDetailProvider = FutureProvider.family
    .autoDispose<Course, int>((ref, courseId) async {
  return ref.watch(courseServiceProvider).getCourseDetail(courseId);
});

class SyllabusModulesScreen extends ConsumerWidget {
  const SyllabusModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Extract Arguments
    final args = ModalRoute.of(context)?.settings.arguments as SyllabusScreenArgs?;

    if (args == null) {
      return const Scaffold(body: Center(child: Text("Error: No course data")));
    }

    final detailAsync = ref.watch(studentCourseDetailProvider(args.courseId));

    return Scaffold(
      appBar: buildAppBar(context, title: args.title),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (course) {
          final modules = course.modules ?? [];
          if (modules.isEmpty) {
            return const Center(child: Text("No content available yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: index == 0, // Open first module by default
                  shape: const Border(),
                  title: Text(
                    module.title,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: module.lessons.map((lesson) {
                    // 3. LOCKING LOGIC
                    // It is locked if: User is NOT enrolled AND Lesson is NOT free
                    final bool isLocked = !args.isEnrolled && !lesson.isFree;

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.grey[200] : Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.lock
                              : (lesson.contentType == 'pdf' ? Icons.picture_as_pdf : Icons.play_arrow),
                          color: isLocked
                              ? Colors.grey
                              : (lesson.contentType == 'pdf' ? Colors.red : Colors.blue),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        lesson.title,
                        style: TextStyle(
                          color: isLocked ? Colors.grey : Colors.black87,
                        ),
                      ),
                      trailing: _buildTrailingWidget(lesson.isFree, isLocked),
                      onTap: () {
                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Purchase the course to unlock this lesson!"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else {
                          // Navigate to Player
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonViewerScreen(lesson: lesson),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      // Only show BottomBar if enrolled (optional UX choice)
      bottomNavigationBar: args.isEnrolled ? FloatingCustomNavBar(currentIndex: 1) : null,
    );
  }

  Widget _buildTrailingWidget(bool isFree, bool isLocked) {
    if (isFree && isLocked) {
      // This case shouldn't happen based on logic, but just in case
      return const Chip(label: Text("Free"), backgroundColor: Colors.greenAccent);
    }
    if (isFree && !isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text("DEMO", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
      );
    }
    if (isLocked) {
      return const Icon(Icons.lock_outline, size: 16, color: Colors.grey);
    }
    return const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey);
  }
}