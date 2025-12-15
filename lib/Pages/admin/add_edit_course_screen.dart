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

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isEditing = false;
  int? _courseId;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if arguments exist (Editing Mode)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Course && !_isEditing) {
      _isEditing = true;
      _courseId = args.courseId;
      _titleController.text = args.title;
      _descController.text = args.description ?? '';
      _priceController.text = args.price.toString();
      _urlController.text = args.thumbnailUrl ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final course = Course(
        courseId: _courseId,
        title: _titleController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        thumbnailUrl: _urlController.text,
      );

      if (_isEditing) {
        await ref.read(adminServicesProvider).updateCourse(_courseId!, course);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Updated!")));
      } else {
        await ref.read(adminServicesProvider).createCourse(course);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Created!")));
      }

      // Refresh the list on the previous screen
      ref.refresh(allCoursesProvider);

      if(mounted) Navigator.pop(context); // Go back

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
              children: [
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL', border: OutlineInputBorder()),
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
}