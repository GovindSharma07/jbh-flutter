import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../app_routes.dart';
import '../../services/admin_services.dart';

class ManageCoursesScreen extends ConsumerWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(allCoursesProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: 'Manage Courses'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Navigate to Add Screen (passing null means "Create Mode")
          Navigator.pushNamed(context, AppRoutes.addEditCourse);
        },
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text("No courses found. Add one!"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    width: 50, height: 50,
                    color: Colors.grey[300],
                    child: course.thumbnailUrl != null
                        ? Image.network(course.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s)=> const Icon(Icons.error))
                        : const Icon(Icons.image),
                  ),
                  title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${course.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        tooltip: 'Manage Syllabus',
                        icon: const Icon(Icons.library_books, color: Colors.green),
                        onPressed: () {
                          // Navigate to ManageSyllabusScreen passing the Course object
                          Navigator.pushNamed(
                            context,
                            AppRoutes.manageSyllabus, // Ensure this route is defined in app_routes.dart
                            arguments: course,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addEditCourse,
                            arguments: course,
                          );
                        },
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text("Delete Course?"),
                              content: const Text("This action cannot be undone."),
                              actions: [
                                TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text("Cancel")),
                                TextButton(onPressed: ()=>Navigator.pop(c,true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(adminServicesProvider).deleteCourse(course.courseId!);
                            ref.refresh(allCoursesProvider); // Refresh list
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}