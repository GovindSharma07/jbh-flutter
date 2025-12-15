import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';
import 'package:jbh_academy/state/apprenticeship_state.dart';
import '../../app_routes.dart';

class ApprenticeshipsScreen extends ConsumerWidget {
  const ApprenticeshipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final asyncList = ref.watch(apprenticeshipListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildAppBar(context, title: 'Apprenticeships'),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("No open positions available."));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(apprenticeshipListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _ApprenticeshipCard(
                    item: item,
                    primaryColor: primaryColor,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.apprenticeshipDetail,
                        // Pass the Model itself or a Map containing ID
                        arguments: {
                          'id': item.id,
                          'title': item.title,
                          'company': item.companyName,
                          'imagePath': item.imageUrl,
                          'description': item.description,
                          'duration': item.duration,
                          'location': item.location,
                          'hasApplied': item.hasApplied,
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingCustomNavBar(),
    );
  }
}

class _ApprenticeshipCard extends StatelessWidget {
  final dynamic item; // Using dynamic to avoid import conflict here, strictly use Apprenticeship model
  final Color primaryColor;
  final VoidCallback onTap;

  const _ApprenticeshipCard({
    required this.item,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 60, height: 60, child: const Icon(Icons.business)),
          ),
        ),
        title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        subtitle: Text(item.companyName),
        trailing: item.hasApplied
            ? const Chip(label: Text("Applied", style: TextStyle(color: Colors.green)))
            : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}