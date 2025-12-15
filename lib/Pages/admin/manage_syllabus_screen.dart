import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../services/admin_services.dart';

// Helper provider to fetch specific course details
final courseDetailProvider = FutureProvider.family.autoDispose<Course, int>((ref, courseId) async {
  return ref.read(adminServicesProvider).getCourseDetail(courseId);
});

class ManageSyllabusScreen extends ConsumerWidget {
  static const String routeName = '/admin/manage-syllabus';

  const ManageSyllabusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Retrieve Course Object or ID from arguments
    final course = ModalRoute.of(context)!.settings.arguments as Course;
    final courseId = course.courseId!;

    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: buildAppBar(context, title: "Manage Content"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModuleDialog(context, ref, courseId),
        label: const Text("Add Module"),
        icon: const Icon(Icons.add),
      ),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (fullCourse) {
          final modules = fullCourse.modules ?? [];

          if (modules.isEmpty) {
            return const Center(child: Text("No modules yet. Add one!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${module.lessons.length} Lessons"),
                  children: [
                    ...module.lessons.map((lesson) => ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(lesson.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                        onPressed: () {
                          // Implement delete lesson logic here
                        },
                      ),
                    )),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.blue),
                      title: const Text("Add Lesson", style: TextStyle(color: Colors.blue)),
                      onTap: () => _showAddLessonDialog(context, ref, module.moduleId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Dialogs ---

  void _showAddModuleDialog(BuildContext context, WidgetRef ref, int courseId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Add Module"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Module Title"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(adminServicesProvider).addModule(courseId, controller.text);
                ref.invalidate(courseDetailProvider(courseId)); // Refresh UI
                if(context.mounted) Navigator.pop(c);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, WidgetRef ref, int moduleId) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Add Lesson"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Video URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                await ref.read(adminServicesProvider).addLesson(
                  moduleId: moduleId,
                  title: titleCtrl.text,
                  contentUrl: urlCtrl.text,
                );
                // We need to invalidate the whole course to see the nested lesson update
                // (Note: To make this cleaner, we should pass courseId to this function)
                // For now, user has to pull-to-refresh or reopen, or we use a global refresh
                if(context.mounted) {
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lesson Added! Refreshing...")));
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}