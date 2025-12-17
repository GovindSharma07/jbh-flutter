import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
// Ensure Course model has isPublished
import '../../app_routes.dart';
import '../../services/admin_services.dart'; // Ensure this has toggleCoursePublishStatus

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
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // TOP SECTION: Image, Info, and Toggle
                    ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Stack(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              image: course.thumbnailUrl != null
                                  ? DecorationImage(
                                image: NetworkImage(course.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: course.thumbnailUrl == null
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),
                          // "FREE" Badge overlay
                          if (course.price == 0)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                color: Colors.green,
                                child: const Text(
                                  "FREE",
                                  style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            // Price Label
                            Text(
                              course.price == 0 ? "Free" : "₹${course.price}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: course.price == 0 ? Colors.green : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Status Badge (Draft/Published)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: course.isPublished ? Colors.green[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: course.isPublished ? Colors.green : Colors.orange,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                course.isPublished ? "Published" : "Draft",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: course.isPublished ? Colors.green[800] : Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TOGGLE SWITCH
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: course.isPublished,
                            activeColor: Colors.green,
                            onChanged: (val) async {
                              // Optimistic UI update or wait for server
                              await ref.read(adminServicesProvider).toggleCoursePublishStatus(course.courseId!, val);
                              ref.refresh(allCoursesProvider); // Refresh list to sync state
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // BOTTOM SECTION: Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Manage Syllabus
                          TextButton.icon(
                            icon: const Icon(Icons.library_books, color: Colors.indigo, size: 20),
                            label: const Text("Syllabus", style: TextStyle(color: Colors.indigo)),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.manageSyllabus,
                                arguments: course,
                              );
                            },
                          ),
                          // Edit
                          TextButton.icon(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            label: const Text("Edit", style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addEditCourse,
                                arguments: course,
                              );
                            },
                          ),
                          // Delete
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            label: const Text("Delete", style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text("Delete Course?"),
                                  content: Text("Are you sure you want to delete '${course.title}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await ref.read(adminServicesProvider).deleteCourse(course.courseId!);
                                ref.refresh(allCoursesProvider);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
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