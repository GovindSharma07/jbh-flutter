import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';
import 'package:jbh_academy/Models/user_model.dart';

import '../../services/admin_services.dart';

// Provider to fetch users
final userListProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  return ref.watch(adminServicesProvider).getAllUsers();
});

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: buildAppBar(context, title: "Manage Users"),
      body: userListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
          if (users.isEmpty) return const Center(child: Text("No users found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      user.role.isNotEmpty ? user.role[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(color: _getRoleColor(user.role), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _confirmDelete(context, ref, user);
                      // Add block logic here if backend supports it
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete User'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'instructor': return Colors.blue;
      default: return Colors.green;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User?"),
        content: Text("Are you sure you want to delete ${user.email}? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminServicesProvider).deleteUser(user.userId);
                ref.invalidate(userListProvider); // Refresh List
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User deleted successfully"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}