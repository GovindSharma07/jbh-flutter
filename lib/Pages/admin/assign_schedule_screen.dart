import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jbh_academy/services/admin_services.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';

class AssignScheduleScreen extends ConsumerStatefulWidget {
  const AssignScheduleScreen({super.key});

  @override
  ConsumerState<AssignScheduleScreen> createState() => _AssignScheduleScreenState();
}

class _AssignScheduleScreenState extends ConsumerState<AssignScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Form State ---
  String? _selectedCourseId;
  String? _selectedInstructorId;

  // Schedule Mode
  String _scheduleType = "recurring"; // 'recurring' or 'one-time'

  // Recurring Fields
  String _selectedDay = "Monday";
  DateTime? _validFrom;
  DateTime? _validTo;

  // One-Time Fields
  DateTime? _specificDate;

  // Time
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Future<void> _selectDate(BuildContext context, {required Function(DateTime) onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourseId == null || _selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Course and Instructor")));
      return;
    }

    if (_scheduleType == 'one-time' && _specificDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select the Date for the class")));
      return;
    }

    try {
      final data = {
        "courseId": _selectedCourseId,
        "instructorId": _selectedInstructorId,
        "scheduleType": _scheduleType,
        "startTime": _startTime.format(context),
        "endTime": _endTime.format(context),
        // Optional / Conditional Fields
        "dayOfWeek": _scheduleType == 'recurring' ? _selectedDay : null,
        "validFrom": _validFrom?.toIso8601String(),
        "validTo": _validTo?.toIso8601String(),
        "specificDate": _specificDate?.toIso8601String(),
      };

      await ref.read(adminServicesProvider).createScheduleSlot(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule Assigned Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Real Data from Providers
    final coursesAsync = ref.watch(allCoursesProvider);
    final instructorsAsync = ref.watch(allInstructorsProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: "Assign Live Class"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- COURSE DROPDOWN ---
              coursesAsync.when(
                data: (courses) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Select Course", border: OutlineInputBorder()),
                  value: _selectedCourseId,
                  items: courses.map((c) => DropdownMenuItem(value: c.courseId.toString(), child: Text(c.title))).toList(),
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                  validator: (val) => val == null ? "Required" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text("Error loading courses: $err"),
              ),
              const SizedBox(height: 16),

              // --- INSTRUCTOR DROPDOWN ---
              instructorsAsync.when(
                data: (instructors) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Assign Instructor", border: OutlineInputBorder()),
                  value: _selectedInstructorId,
                  items: instructors.map((u) => DropdownMenuItem(value: u.userId.toString(), child: Text(u.fullName ?? "Unknown"))).toList(),
                  onChanged: (val) => setState(() => _selectedInstructorId = val),
                  validator: (val) => val == null ? "Required" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text("Error loading instructors: $err"),
              ),
              const SizedBox(height: 24),

              // --- TYPE TOGGLE ---
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: "recurring", label: Text("Recurring (Weekly)")),
                  ButtonSegment(value: "one-time", label: Text("One-Time Event")),
                ],
                selected: {_scheduleType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _scheduleType = newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              // --- CONDITIONAL UI: RECURRING ---
              if (_scheduleType == 'recurring') ...[
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: const InputDecoration(labelText: "Day of Week", border: OutlineInputBorder()),
                  items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) => setState(() => _selectedDay = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: "Starts From (Optional)",
                        selectedDate: _validFrom,
                        onTap: () => _selectDate(context, onPicked: (d) => setState(() => _validFrom = d)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DatePickerField(
                        label: "Ends On (Optional)",
                        selectedDate: _validTo,
                        onTap: () => _selectDate(context, onPicked: (d) => setState(() => _validTo = d)),
                      ),
                    ),
                  ],
                ),
              ]
              // --- CONDITIONAL UI: ONE-TIME ---
              else ...[
                _DatePickerField(
                  label: "Select Date",
                  selectedDate: _specificDate,
                  onTap: () => _selectDate(context, onPicked: (d) => setState(() => _specificDate = d)),
                ),
              ],

              const SizedBox(height: 24),

              // --- TIME PICKERS (Always Visible) ---
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text("Start Time"),
                      subtitle: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _startTime);
                        if (t != null) setState(() => _startTime = t);
                      },
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: const Text("End Time"),
                      subtitle: Text(_endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _endTime);
                        if (t != null) setState(() => _endTime = t);
                      },
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitSchedule,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(15)),
                  child: const Text("Assign Schedule", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for Date Fields
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : "Select Date",
          style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }
}