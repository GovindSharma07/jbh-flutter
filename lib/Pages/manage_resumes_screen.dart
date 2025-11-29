// lib/Pages/profile/manage_resumes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/state/apprenticeship_state.dart'; // Accessing resumeListProvider
import 'package:jbh_academy/services/resume_service.dart';

class ManageResumesScreen extends ConsumerWidget {
  const ManageResumesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeListAsync = ref.watch(resumeListProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context, title: "Manage Resumes"),
      body: resumeListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (resumes) {
          if (resumes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No resumes uploaded yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.picture_as_pdf, color: primaryColor),
                  ),
                  title: Text(resume.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "ID: ${resume.id}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, resume.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const FloatingCustomNavBar(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int resumeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Resume?"),
        content: const Text("This will remove the resume from your saved list. Existing applications using this resume will not be affected."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              try {
                // 1. Call API
                await ref.read(resumeServiceProvider).deleteResume(resumeId);
                // 2. Refresh the list
                ref.invalidate(resumeListProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Resume deleted successfully"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}