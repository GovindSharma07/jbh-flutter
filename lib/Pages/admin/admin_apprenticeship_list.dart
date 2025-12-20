import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/app_routes.dart'; // Import Routes
// IMP: Import the state file where 'apprenticeshipListProvider' is defined
import 'package:jbh_academy/state/apprenticeship_state.dart';

class AdminApprenticeshipListScreen extends ConsumerStatefulWidget {
  const AdminApprenticeshipListScreen({super.key});

  @override
  ConsumerState<AdminApprenticeshipListScreen> createState() => _AdminApprenticeshipListScreenState();
}

class _AdminApprenticeshipListScreenState extends ConsumerState<AdminApprenticeshipListScreen> {
  @override
  Widget build(BuildContext context) {
    // This will now work because we imported 'apprenticeship_state.dart'
    final jobsAsync = ref.watch(apprenticeshipListProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: "Select Job"),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (jobs) {
          if (jobs.isEmpty) return const Center(child: Text("No apprenticeships posted."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(job.imageUrl),
                        fit: BoxFit.cover,
                        onError: (e, s) => {},
                      ),
                    ),
                    child: job.imageUrl.isEmpty ? const Icon(Icons.work) : null,
                  ),
                  title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${job.companyName} • ${job.location}"),
                  trailing: const Icon(Icons.people_outline),
                  onTap: () {
                    // Navigate using Named Route & Arguments
                    Navigator.pushNamed(
                      context,
                      AppRoutes.adminApprenticeshipApplicants,
                      arguments: ApprenticeshipApplicantsArgs(
                        apprenticeshipId: job.id,
                        jobTitle: job.title,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}