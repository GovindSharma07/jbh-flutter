import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/services/admin_services.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';

class AssignScheduleScreen extends ConsumerStatefulWidget {
  const AssignScheduleScreen({super.key});

  @override
  ConsumerState<AssignScheduleScreen> createState() => _AssignScheduleScreenState();
}

class _AssignScheduleScreenState extends ConsumerState<AssignScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selection State
  String? _selectedCourseId;
  String? _selectedInstructorId;
  String _selectedDay = "Monday";
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Mock Data lists (In real app, fetch these via providers)
  // final _courses = ref.watch(allCoursesProvider);
  // final _instructors = ref.watch(allInstructorsProvider);

  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Course and Instructor")));
      return;
    }

    try {
      // Call your Admin Service to create the timetable slot
      await ref.read(adminServicesProvider).createScheduleSlot({
        "courseId": _selectedCourseId,
        "instructorId": _selectedInstructorId,
        "dayOfWeek": _selectedDay,
        "startTime": _startTime.format(context),
        "endTime": _endTime.format(context),
      });

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule Assigned Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // You should use FutureBuilder or Riverpod .when to fetch these lists
    // For now, I am showing the UI structure
    return Scaffold(
      appBar: buildAppBar(context, title: "Assign Live Class"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Select Course Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Course", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "1", child: Text("Python Basics")),
                  DropdownMenuItem(value: "2", child: Text("Advanced Flutter")),
                ],
                onChanged: (val) => setState(() => _selectedCourseId = val),
              ),
              const SizedBox(height: 16),

              // 2. Select Instructor Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Assign Instructor", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "101", child: Text("Mr. Mohit Lochab")),
                  DropdownMenuItem(value: "102", child: Text("Mr. Ashish Singh")),
                ],
                onChanged: (val) => setState(() => _selectedInstructorId = val),
              ),
              const SizedBox(height: 16),

              // 3. Select Day
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(labelText: "Day of Week", border: OutlineInputBorder()),
                items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (val) => setState(() => _selectedDay = val!),
              ),
              const SizedBox(height: 16),

              // 4. Time Pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text("Start Time"),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _startTime);
                        if (t != null) setState(() => _startTime = t);
                      },
                      tileColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: const Text("End Time"),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _endTime);
                        if (t != null) setState(() => _endTime = t);
                      },
                      tileColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitSchedule,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(15)),
                  child: const Text("Assign Schedule", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}