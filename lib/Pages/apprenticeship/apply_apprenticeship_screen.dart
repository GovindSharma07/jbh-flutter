import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/state/apprenticeship_state.dart';

import '../../app_routes.dart';

class ApplyApprenticeshipScreen extends ConsumerStatefulWidget {
  const ApplyApprenticeshipScreen({super.key});

  @override
  ConsumerState<ApplyApprenticeshipScreen> createState() => _ApplyState();
}

class _ApplyState extends ConsumerState<ApplyApprenticeshipScreen> {
  int? _selectedResumeId;
  final TextEditingController _msgCtrl = TextEditingController();

  // Logic to Pick File and Upload Atomically
  void _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      // Call the controller
      final newId = await ref.read(applicationControllerProvider.notifier)
          .uploadAndSelectResume(file.path!, file.name);

      // If upload successful, select the new resume ID
      if (newId != null) {
        setState(() => _selectedResumeId = newId);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resume uploaded successfully!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed from detail screen
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final int apprenticeshipId = args['id'];

    final primaryColor = Theme.of(context).primaryColor;
    final resumeListAsync = ref.watch(resumeListProvider);
    final appState = ref.watch(applicationControllerProvider);

    // Listener for final submission success/error
    ref.listen(applicationControllerProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application Submitted!"), backgroundColor: Colors.green));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
              (route) => false,
        );
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context, title: "Apply Now"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Resume", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // 1. Resume Dropdown (from existing list)
            resumeListAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const Text("Could not load resumes"),
              data: (resumes) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedResumeId,
                    hint: const Text("Choose existing resume"),
                    isExpanded: true,
                    items: resumes.map((r) => DropdownMenuItem<int>(
                      value: r.id,
                      child: Text(r.name, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedResumeId = val),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Center(child: Text("- OR -", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),

            // 2. Upload New Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: appState.isLoading ? null : _pickAndUploadFile,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Upload New Resume (PDF/Doc)"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Message Field
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Why should we hire you? (Optional)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (appState.isLoading || _selectedResumeId == null)
                    ? null
                    : () {
                  ref.read(applicationControllerProvider.notifier)
                      .submitApplication(apprenticeshipId, _selectedResumeId!, _msgCtrl.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: appState.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Submit Application", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingCustomNavBar(),
    );
  }
}