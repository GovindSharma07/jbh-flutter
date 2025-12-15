import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/Pages/resume/resume_viewer_screen.dart';
import 'package:jbh_academy/state/apprenticeship_state.dart';
import 'package:jbh_academy/services/resume_service.dart';

class ManageResumesScreen extends ConsumerStatefulWidget {
  const ManageResumesScreen({super.key});

  @override
  ConsumerState<ManageResumesScreen> createState() => _ManageResumesScreenState();
}

class _ManageResumesScreenState extends ConsumerState<ManageResumesScreen> {
  bool _isUploading = false; // To show loading state

  // --- 1. Method to Upload Resume ---
  Future<void> _pickAndUploadResume() async {
    try {
      // A. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDFs
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);

        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        // B. Call Service
        await ref.read(resumeServiceProvider).uploadResume(filePath, fileName);

        // C. Refresh List
        ref.invalidate(resumeListProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resume uploaded successfully!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // --- 2. Method to View Resume ---
  void _viewResume(String? url, String fileName) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid URL")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeViewerScreen(
          pdfUrl: url,
          title: fileName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumeListAsync = ref.watch(resumeListProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context, title: "Manage Resumes"),

      // --- Floating Action Button for Upload ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadResume,
        backgroundColor: primaryColor,
        icon: _isUploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_file, color: Colors.white),
        label: Text(_isUploading ? "Uploading..." : "Upload Resume", style: const TextStyle(color: Colors.white)),
      ),

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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.picture_as_pdf, color: primaryColor),
                  ),
                  title: Text(resume.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Tap to view",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  // --- CLICK TO VIEW ---
                  onTap: () => _viewResume(resume.fileUrl,resume.name),

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
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(resumeServiceProvider).deleteResume(resumeId);
                ref.invalidate(resumeListProvider); // Auto-refresh list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted!")));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
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