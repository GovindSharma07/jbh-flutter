import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/floating_custom_nav_bar.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../Models/lesson_model.dart';
import '../../services/course_service.dart';
import '../../services/student_service.dart';
import 'course/lesson_viewer_screen.dart';
import 'live_class/live_class_screen.dart';

// 1. Arguments Class
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

// Provider to fetch course details
final studentCourseDetailProvider = FutureProvider.family
    .autoDispose<Course, int>((ref, courseId) async {
  return ref.watch(courseServiceProvider).getCourseDetail(courseId);
});

class SyllabusModulesScreen extends ConsumerStatefulWidget {
  const SyllabusModulesScreen({super.key});

  @override
  ConsumerState<SyllabusModulesScreen> createState() => _SyllabusModulesScreenState();
}

class _SyllabusModulesScreenState extends ConsumerState<SyllabusModulesScreen> {

  // Logic to Join Live Class directly from Syllabus
  Future<void> _handleJoinLive(int lessonId) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // NOTE: In a real scenario, you need the 'liveLectureId'.
      // If your Lesson model doesn't have it, you might need to fetch it or
      // assume the backend sends it in a field.
      // For this example, we assume we fetch the active lecture for this lesson.

      // Temporary: We are just calling the join API.
      // Ideally, pass the real liveLectureId associated with this lesson.
      final data = await ref.read(studentServiceProvider).joinLiveLecture(lessonId);

      if (!mounted) return;
      Navigator.pop(context); // Close Loading

      // Navigate to VideoSDK Room
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveClassScreen(
            roomId: data['roomId'],
            token: data['token'],
            isInstructor: false,
            displayName: "Student",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close Loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not join: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as SyllabusScreenArgs?;

    if (args == null) {
      return const Scaffold(body: Center(child: Text("Error: No course data")));
    }

    final detailAsync = ref.watch(studentCourseDetailProvider(args.courseId));
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar(context, title: args.title),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error loading content: $e")),
        data: (course) {
          final modules = course.modules ?? [];
          if (modules.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final module = modules[index];
              return _buildModuleCard(module, args.isEnrolled, index == 0, primaryColor);
            },
          );
        },
      ),
      bottomNavigationBar: args.isEnrolled
          ? FloatingCustomNavBar(currentIndex: 1)
          : _buildEnrollmentFooter(args.courseId, primaryColor),
    );
  }

  Widget _buildModuleCard(dynamic module, bool isEnrolled, bool isFirst, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          initiallyExpanded: isFirst,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: const Border(), // Removes default divider borders
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              "${module.order ?? (module.title.length > 0 ? module.title[0] : '#')}",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            module.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text("${module.lessons?.length ?? 0} Lessons"),
          children: (module.lessons as List<Lesson>).map((lesson) {
            return _buildLessonTile(lesson, isEnrolled);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson, bool isEnrolled) {
    // 1. Determine Status
    final bool isLive = lesson.contentType == 'live';
    final bool isLocked = !isEnrolled && !lesson.isFree && !isLive; // Live might be free/demo?

    IconData icon;
    Color iconColor;
    Color tileColor;

    if (isLive) {
      icon = Icons.sensors; // Live Icon
      iconColor = Colors.red;
      tileColor = Colors.red.withOpacity(0.05);
    } else if (lesson.contentType == 'pdf') {
      icon = Icons.picture_as_pdf;
      iconColor = Colors.orange;
      tileColor = Colors.transparent;
    } else {
      icon = Icons.play_circle_fill;
      iconColor = Colors.blue;
      tileColor = Colors.transparent;
    }

    if (isLocked) {
      icon = Icons.lock;
      iconColor = Colors.grey;
    }

    return Container(
      color: tileColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
            color: isLocked ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: isLive
            ? const Text("HAPPENING NOW", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
            : Text(lesson.duration != null ? "${lesson.duration} mins" : "Lesson", style: const TextStyle(fontSize: 12)),

        trailing: isLocked
            ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
            : isLive
            ? ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(60, 30),
          ),
          onPressed: () => _handleJoinLive(lesson.lessonId),
          child: const Text("JOIN"),
        )
            : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),

        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Enroll to unlock this lesson!")),
            );
          } else if (isLive) {
            _handleJoinLive(lesson.lessonId);
          } else {
            // Open Viewer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonViewerScreen(lesson: lesson),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No content uploaded yet.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Footer for Non-Enrolled Users to encourage purchase
  Widget? _buildEnrollmentFooter(int courseId, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // Navigate back to details or trigger payment
            Navigator.pop(context);
          },
          child: const Text("Unlock Full Course", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}