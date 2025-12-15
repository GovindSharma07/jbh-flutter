import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
import '../../Components/floating_custom_nav_bar.dart';
import '../../app_routes.dart';
import '../../services/course_service.dart'; // Import Service
import '../../Models/course_model.dart';

class CourseSelectionScreen extends ConsumerStatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  ConsumerState<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the list of courses from the backend
    final courseListAsync = ref.watch(courseListProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: "Courses"),
      body: Column(
        children: [
          _buildTabBarAndFilter(context),
          Expanded(
            child: courseListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allCourses) {
                // Filter courses locally for tabs
                final paidCourses = allCourses.where((c) => c.price > 0).toList();
                final freeCourses = allCourses.where((c) => c.price == 0).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCourseList(context, paidCourses, isPaid: true),
                    _buildCourseList(context, freeCourses, isPaid: false),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 80), // Space for nav bar
        ],
      ),
      bottomNavigationBar: FloatingCustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildTabBarAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: "Paid Course"),
          Tab(text: "Free Course"),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, List<Course> courses, {required bool isPaid}) {
    if (courses.isEmpty) {
      return Center(child: Text("No ${isPaid ? 'Paid' : 'Free'} courses available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60, height: 60,
          color: Colors.grey[200],
          child: course.thumbnailUrl != null
              ? Image.network(course.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.broken_image))
              : const Icon(Icons.image),
        ),
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(course.price == 0 ? "Free" : "₹${course.price}"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Navigate to Detail Screen with the Course Object
            Navigator.pushNamed(
              context,
              AppRoutes.courseDetail,
              arguments: course, // Pass the whole object
            );
          },
          child: Text(course.price == 0 ? "View" : "Buy"),
        ),
      ),
    );
  }
}