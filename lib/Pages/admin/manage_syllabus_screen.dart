import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../Models/lesson_model.dart';
import '../../Models/module_model.dart';
import '../../services/admin_services.dart';
import '../course/lesson_viewer_screen.dart';

// Helper provider to fetch specific course details
final courseDetailProvider = FutureProvider.family.autoDispose<Course, int>((ref, courseId) async {
  return ref.read(adminServicesProvider).getCourseDetail(courseId);
});
class ManageSyllabusScreen extends ConsumerStatefulWidget {
  const ManageSyllabusScreen({super.key});

  @override
  ConsumerState<ManageSyllabusScreen> createState() => _ManageSyllabusScreenState();
}

class _ManageSyllabusScreenState extends ConsumerState<ManageSyllabusScreen> {
  // We keep local state for reordering to make UI snappy before API call
  List<Module>? _localModules;
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
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
          // FIX: Update local list whenever we get fresh data from the provider,
          // unless we are currently busy reordering (to prevent UI glitches during save).
          if (_localModules == null || !_isReordering) {
            _localModules = List.from(fullCourse.modules ?? []);
            // Note: Backend should handle sorting, but you can keep this safety sort if you want
            _localModules!.sort((a, b) => a.order.compareTo(b.order));
          }

          if (_localModules!.isEmpty) return const Center(child: Text("No modules yet. Add one!"));
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _localModules!.length,
            onReorder: (oldIndex, newIndex) => _onReorderModules(oldIndex, newIndex, courseId),
            itemBuilder: (context, index) {
              final module = _localModules![index];
              return Card(
                key: ValueKey(module.moduleId), // Important for ReorderableListView
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: const Icon(Icons.drag_handle), // Drag Handle
                  title:Row(
                    children: [
                      Expanded(child: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                      // NEW: Module Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            context,
                            module.title,
                                () => _deleteModule(module.moduleId, courseId)
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text("${module.lessons.length} Lessons"),
                  children: [
                    // Button to Open Reorder Lessons Dialog
                    if(module.lessons.length > 1)
                      TextButton.icon(
                        icon: const Icon(Icons.sort, size: 18),
                        label: const Text("Reorder Lessons"),
                        onPressed: () => _showReorderLessonsDialog(context, ref, module, courseId),
                      ),

                    // Lesson List
                    ...module.lessons.map((lesson) => ListTile(
                      // --- CHANGED PDF ICON HERE ---
                      leading: Icon(
                        lesson.contentType == 'pdf' ? Icons.picture_as_pdf : Icons.play_circle_fill,
                        color: lesson.contentType == 'pdf' ? Colors.red : Colors.blue,
                      ),
                      title: Text(lesson.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonViewerScreen(lesson: lesson),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                        onPressed:() => _confirmDelete(
                            context,
                            lesson.title,
                                () => _deleteLesson(lesson.lessonId, courseId)
                        ),
                      ),
                    )),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.blue),
                      title: const Text("Add Lesson", style: TextStyle(color: Colors.blue)),
                      onTap: () => _showAddLessonDialog(context, ref, module.moduleId, courseId),
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

  // --- NEW: Helper for Confirmation Dialog ---
  Future<void> _confirmDelete(BuildContext context, String title, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$title'? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              onConfirm();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- NEW: Delete Logic ---
  Future<void> _deleteModule(int moduleId, int courseId) async {
    try {
      await ref.read(adminServicesProvider).deleteModule(moduleId);
      ref.invalidate(courseDetailProvider(courseId)); // Refresh UI
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Module Deleted")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deleteLesson(int lessonId, int courseId) async {
    try {
      await ref.read(adminServicesProvider).deleteLesson(lessonId);
      ref.invalidate(courseDetailProvider(courseId)); // Refresh UI
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lesson Deleted")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  // --- Module Reordering Logic ---
  Future<void> _onReorderModules(int oldIndex, int newIndex, int courseId) async {
    setState(() {
      _isReordering = true;
      if (oldIndex < newIndex) newIndex -= 1;
      final item = _localModules!.removeAt(oldIndex);
      _localModules!.insert(newIndex, item);
    });

    // Prepare API Payload
    final updates = _localModules!.asMap().entries.map((e) => {
      'id': e.value.moduleId,
      'order': e.key
    }).toList();

    await ref.read(adminServicesProvider).reorderModules(courseId, updates);

    // Refresh to sync with backend completely
    ref.invalidate(courseDetailProvider(courseId));
    setState(() => _isReordering = false);
  }

  // --- Lesson Reordering Dialog ---
  void _showReorderLessonsDialog(BuildContext context, WidgetRef ref, Module module, int courseId) {
    List<Lesson> localLessons = List.from(module.lessons);
    localLessons.sort((a,b) => (a.lessonOrder).compareTo(b.lessonOrder)); // Ensure sort is used in Model

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Reorder: ${module.title}"),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ReorderableListView.builder(
                itemCount: localLessons.length,
                onReorder: (oldIndex, newIndex) {
                  setStateDialog(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = localLessons.removeAt(oldIndex);
                    localLessons.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final lesson = localLessons[index];
                  return ListTile(
                    key: ValueKey(lesson.lessonId),
                    leading: const Icon(Icons.drag_indicator, color: Colors.grey),
                    title: Text(lesson.title),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final updates = localLessons.asMap().entries.map((e) => {
                    'id': e.value.lessonId,
                    'order': e.key
                  }).toList();

                  await ref.read(adminServicesProvider).reorderLessons(module.moduleId, updates);
                  ref.invalidate(courseDetailProvider(courseId));
                  if(mounted) Navigator.pop(c);
                },
                child: const Text("Save Order"),
              )
            ],
          );
        },
      ),
    );
  }

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

  void _showAddLessonDialog(BuildContext context, WidgetRef ref, int moduleId,int courseId) {
    final titleCtrl = TextEditingController();

    // State variables for the dialog
    PlatformFile? selectedFile;
    String contentType = 'video'; // Default
    bool isFree = false;
    bool isUploading = false;
    double uploadProgress = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while uploading
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {

          // Helper to pick file
          Future<void> pickFile() async {
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: contentType == 'video' ? FileType.video : FileType.custom,
                allowedExtensions: contentType == 'pdf' ? ['pdf'] : null,
                withData: true, // Needed for Web
              );

              if (result != null) {
                setState(() {
                  selectedFile = result.files.first;
                  // Auto-fill title if empty
                  if(titleCtrl.text.isEmpty) {
                    titleCtrl.text = selectedFile!.name.split('.').first;
                  }
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          }

          // Helper to Submit
          Future<void> submit() async {
            if (titleCtrl.text.isEmpty) return;
            if (selectedFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a file")));
              return;
            }

            setState(() {
              isUploading = true;
              uploadProgress = 0.0;
            });

            try {
              // 1. Upload the File
              final url = await ref.read(adminServicesProvider).uploadLessonContent(
                selectedFile!,
                onProgress: (val) {
                  setState(() => uploadProgress = val);
                },
              );

              // 2. Create Lesson in Backend
              await ref.read(adminServicesProvider).addLesson(
                moduleId: moduleId,
                title: titleCtrl.text,
                contentUrl: url,
                contentType: contentType,
                isFree: isFree,
              );

              ref.invalidate(courseDetailProvider(courseId)); // Refresh UI

              if (context.mounted) {
                Navigator.pop(context); // Close Dialog
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lesson Uploaded & Added!")));
                // Refresh logic here if needed (e.g. ref.refresh)
              }
            } catch (e) {
              print(e.toString());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
                setState(() => isUploading = false);
              }
            }
          }

          return AlertDialog(
            title: const Text("Add New Lesson"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Content Type Selector
                  DropdownButtonFormField<String>(
                    initialValue: contentType,
                    decoration: const InputDecoration(labelText: "Content Type", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'video', child: Text("Video Lesson")),
                      DropdownMenuItem(value: 'pdf', child: Text("PDF Document")),
                    ],
                    onChanged: isUploading ? null : (val) {
                      setState(() {
                        contentType = val!;
                        selectedFile = null; // Reset file if type changes
                      });
                    },
                  ),
                  const SizedBox(height: 15),
              
                  // 2. Title Input
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "Lesson Title", border: OutlineInputBorder()),
                    enabled: !isUploading,
                  ),
                  const SizedBox(height: 15),
              
                  // 3. File Picker Area
                  GestureDetector(
                    onTap: isUploading ? null : pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            contentType == 'video' ? Icons.video_library : Icons.picture_as_pdf,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFile != null ? selectedFile!.name : "Tap to select ${contentType == 'video' ? 'Video' : 'PDF'}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: selectedFile != null ? Colors.black : Colors.grey[600],
                                  fontWeight: selectedFile != null ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                          ),
                          if (selectedFile != null && !isUploading)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        ],
                      ),
                    ),
                  ),
              
                  // 4. Progress Bar (Only visible during upload)
                  if (isUploading) ...[
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: uploadProgress),
                    const SizedBox(height: 5),
                    Text(
                      "Uploading: ${(uploadProgress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
              
                  // 5. Checkbox
                  if (!isUploading)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Is this a Free/Demo lesson?"),
                      value: isFree,
                      onChanged: (val) => setState(() => isFree = val!),
                    ),
                ],
              ),
            ),
            actions: [
              if (!isUploading)
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Cancel"),
                ),
              ElevatedButton(
                onPressed: isUploading ? null : submit,
                child: Text(isUploading ? "Please Wait..." : "Upload & Add"),
              ),
            ],
          );
        },
      ),
    );
  }
}