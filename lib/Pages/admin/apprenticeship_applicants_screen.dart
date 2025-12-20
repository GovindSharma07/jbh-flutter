import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/services/api_service.dart';

class ApprenticeshipApplicantsScreen extends ConsumerStatefulWidget {
  final int apprenticeshipId;
  final String jobTitle;

  const ApprenticeshipApplicantsScreen({
    super.key,
    required this.apprenticeshipId,
    required this.jobTitle,
  });

  @override
  ConsumerState<ApprenticeshipApplicantsScreen> createState() => _ApprenticeshipApplicantsScreenState();
}

class _ApprenticeshipApplicantsScreenState extends ConsumerState<ApprenticeshipApplicantsScreen> {
  bool _isLoading = true;
  List<dynamic> _applicants = [];

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    try {
      final dio = ref.read(dioProvider);

      // Call the backend with the Filter ID
      final response = await dio.get(
        '/admin/applications',
        queryParameters: {'apprenticeshipId': widget.apprenticeshipId},
      );

      if (mounted) {
        setState(() {
          _applicants = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading applicants: $e")));
    }
  }

  // --- CSV DOWNLOAD FUNCTION ---
  Future<void> _downloadExcel() async {
    if (_applicants.isEmpty) return;

    try {
      // 1. Prepare Data for CSV
      List<List<dynamic>> rows = [];

      // Headers
      rows.add(["Name", "Email", "Phone", "Status", "Applied Date", "Resume Link", "Cover Letter"]);

      // Rows
      for (var app in _applicants) {
        rows.add([
          app['user']['full_name'] ?? 'N/A',
          app['user']['email'] ?? 'N/A',
          app['user']['phone'] ?? 'N/A',
          app['status'] ?? 'Pending',
          app['submitted_at'] ?? '',
          app['resume_url'] ?? 'N/A',
          app['message'] ?? 'N/A',
        ]);
      }

      // 2. Convert to CSV String
      String csvData = const ListToCsvConverter().convert(rows);

      // 3. Save to Temp File
      final directory = await getTemporaryDirectory();
      final fileName = "${widget.jobTitle.replaceAll(RegExp(r'\s+'), '_')}_Applicants.csv";
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsString(csvData);

      // 4. Share/Open (Works on both Android & iOS)
      await Share.shareXFiles([XFile(path)], text: 'Applicants list for ${widget.jobTitle}');

    } catch (e) {
      print("Export Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to export file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: "Applicants"),
      body: Column(
        children: [
          // Header & Download Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jobTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                    Text("${_applicants.length} Applications"),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _applicants.isEmpty ? null : _downloadExcel,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text("Export"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _applicants.isEmpty
                ? const Center(child: Text("No applications found for this job."))
                : ListView.builder(
              itemCount: _applicants.length,
              itemBuilder: (context, index) {
                final app = _applicants[index];
                final user = app['user'];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  title: Text(user['full_name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(app['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (app['status'] ?? 'pending').toUpperCase(),
                      style: TextStyle(
                          color: _getStatusColor(app['status']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  onTap: () {
                    // Optional: Show full details or open Resume URL
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}