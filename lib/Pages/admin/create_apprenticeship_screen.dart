import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/services/apprenticeship_service.dart';

class CreateApprenticeshipScreen extends ConsumerStatefulWidget {
  const CreateApprenticeshipScreen({super.key});

  @override
  ConsumerState<CreateApprenticeshipScreen> createState() => _CreateState();
}

class _CreateState extends ConsumerState<CreateApprenticeshipScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _stipendCtrl = TextEditingController();

  // Image State
  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _durationCtrl.dispose();
    _stipendCtrl.dispose();
    super.dispose();
  }

  // 1. Pick Image Logic
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedImage = File(result.files.single.path!);
      });
    }
  }

  // 2. Submit Logic
  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a company logo"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String imageUrl = "";

      // Step A: Upload Image
      if (_pickedImage != null) {
        final service = ref.read(apprenticeshipServiceProvider);
        String fileName = _pickedImage!.path.split('/').last;
        // Upload to Cloud via Backend
        imageUrl = await service.uploadJobImage(_pickedImage!.path, fileName);
      }

      // Step B: Create Job Record with the Cloud URL
      final data = {
        "title": _titleCtrl.text.trim(),
        "company_name": _companyCtrl.text.trim(),
        "description": _descCtrl.text.trim(),
        "location": _locationCtrl.text.trim(),
        "duration": _durationCtrl.text.trim(),
        "stipend": double.tryParse(_stipendCtrl.text) ?? 0,
        "image_url": imageUrl,
      };

      await ref.read(apprenticeshipServiceProvider).createApprenticeship(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job Posted Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to Admin Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: buildAppBar(context, title: "Post New Job"),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Company Logo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // --- Image Picker UI ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _pickedImage != null
                          ? DecorationImage(
                        image: FileImage(_pickedImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _pickedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: primaryColor, size: 30),
                        const SizedBox(height: 4),
                        Text("Upload Logo", style: TextStyle(color: primaryColor, fontSize: 12)),
                      ],
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Job Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildTextField(_titleCtrl, "Job Title", "e.g. Flutter Dev"),
              _buildTextField(_companyCtrl, "Company Name", "e.g. Google"),

              Row(
                children: [
                  Expanded(child: _buildTextField(_locationCtrl, "Location", "e.g. Remote")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_durationCtrl, "Duration", "e.g. 6 Months")),
                ],
              ),

              _buildTextField(_stipendCtrl, "Stipend (Monthly)", "e.g. 15000", isNumber: true),

              _buildTextField(_descCtrl, "Description", "Enter details...", maxLines: 5),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Post Job", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (val) => val!.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}