import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/app_routes.dart';
import 'package:jbh_academy/state/auth_notifier.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Apprenticeships Section ---
            const Text(
              "Apprenticeships",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _AdminMenuCard(
                  icon: Icons.work,
                  label: "Post New Job",
                  color: Colors.blue,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.createJob),
                ),
                _AdminMenuCard(
                  icon: Icons.assignment,
                  label: "View Applications",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.adminApprenticeshipList);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 2. NEW: Course Management Section ---
            const Text(
              "Course Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _AdminMenuCard(
                  icon: Icons.menu_book_rounded,
                  label: "Manage Courses",
                  color: Colors.purple, // Distinct color for Courses
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.manageCourses),
                ),
                _AdminMenuCard(
                  icon: Icons.analytics_outlined,
                  label: "Course Stats",
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Coming Soon: Course Analytics"),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 3. NEW: Timetable / Live Classes Section ---
            const Text(
              "Live Classes & Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _AdminMenuCard(
                  icon: Icons.calendar_month,
                  label: "Assign Schedule",
                  color: Colors.teal,
                  // Ensure 'assignSchedule' is defined in your AppRoutes
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.assignSchedule),
                ),
                _AdminMenuCard(
                  icon: Icons.history,
                  label: "View Time Table",
                  color: Colors.teal,
                  onTap: () {
                    // Placeholder for a screen to view/delete slots
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Feature coming soon")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 3. User Management Section ---
            const Text(
              "User Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _AdminMenuCard(
                  icon: Icons.people_alt,
                  label: "Manage Users",
                  color: Colors.orange,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.manageUsers),
                ),
                _AdminMenuCard(
                  icon: Icons.person_add,
                  label: "Create Admin/Instructor",
                  color: Colors.orange,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.createUser),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AdminMenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
