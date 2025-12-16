import 'dart:io';
import 'package:file_picker/file_picker.dart'; // 1. Import File Picker
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../services/admin_services.dart';

class AddEditCourseScreen extends ConsumerStatefulWidget {
  const AddEditCourseScreen({super.key});

  @override
  ConsumerState<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends ConsumerState<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isEditing = false;
  int? _courseId;
  bool _isLoading = false;

  // 2. State for File Picker
  PlatformFile? _pickedFile;
  String? _existingImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Course && !_isEditing) {
      _isEditing = true;
      _courseId = args.courseId;
      _titleController.text = args.title;
      _descController.text = args.description ?? '';
      _priceController.text = args.price.toString();
      _existingImageUrl = args.thumbnailUrl;
    }
  }

  // 3. Pick Image Function
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Restrict to images
        withData: true, // Important for Web to get bytes
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking file: $e")));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a thumbnail image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _existingImageUrl;

      // 4. Upload if new file selected
      if (_pickedFile != null) {
        finalImageUrl = await ref.read(adminServicesProvider).uploadCourseImage(_pickedFile!);
      }

      final course = Course(
        courseId: _courseId,
        title: _titleController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        thumbnailUrl: finalImageUrl,
      );

      if (_isEditing) {
        await ref.read(adminServicesProvider).updateCourse(_courseId!, course);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Updated!")));
      } else {
        await ref.read(adminServicesProvider).createCourse(course);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Created!")));
      }

      ref.refresh(allCoursesProvider);
      if(mounted) Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: _isEditing ? 'Edit Course' : 'Add Course'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 5. Image Preview UI
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    // Helper method to decide what image source to show
                    child: _buildImagePreview(),
                  ),
                ),
                if (_pickedFile != null || _existingImageUrl != null)
                  Center(
                      child: TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          label: const Text("Change Thumbnail")
                      )
                  ),

                const SizedBox(height: 20),
                // Form Fields
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Course Title', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Price is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEditing ? 'Update Course' : 'Create Course'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Helper Widget to Render Preview
  Widget _buildImagePreview() {
    // A. If user picked a file
    if (_pickedFile != null) {
      if (kIsWeb) {
        // Web: Show from bytes
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(_pickedFile!.bytes!, fit: BoxFit.cover),
        );
      } else {
        // Mobile: Show from path
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(_pickedFile!.path!), fit: BoxFit.cover),
        );
      }
    }

    // B. If editing and has existing URL
    else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error, color: Colors.red)),
        ),
      );
    }

    // C. Default Placeholder
    else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("Tap to add Thumbnail", style: TextStyle(color: Colors.grey)),
        ],
      );
    }
  }
}