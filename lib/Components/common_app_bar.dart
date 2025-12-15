import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_routes.dart';
import '../state/auth_notifier.dart';

AppBar buildAppBar(BuildContext context, {String title = ''}) {
  // Define the primary color, as it's used in multiple places
  Color primaryColor = Theme.of(context).primaryColor;

  return AppBar(
    // 1. Change background color to white
    backgroundColor: Colors.white,
    // 2. Change elevation to 2
    elevation: 2.0,
    shadowColor: primaryColor,
    // 3. Change leading icon color to be visible on white
    leading: IconButton(
      icon: Image.asset(
        'assets/icons/drawer_icon.png', // <-- Your image path
        width: 24,
        height: 24,
        // Tint the icon to the primary color
        color: primaryColor,
      ),
      onPressed: () {
        // Handle menu tap
        Scaffold.of(context).openDrawer(); // Ensure this opens the drawer if present
      },
    ),
    // Add the title property
    title: Text(
      title,
      style: TextStyle(
        color: primaryColor, // Title text is primary color
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,

    actions: [

      // --- LOGOUT BUTTON START ---
      Consumer(
        builder: (context, ref, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.redAccent, // Distinct color for logout (optional) or use primaryColor
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'Logout',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed: () async {
                // 1. Perform Logout (Clear session & state)
                await ref.read(authNotifierProvider.notifier).logout();

                // 2. Clear all background screens and navigate to Login
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                        (route) => false, // This condition ensures all previous routes are removed
                  );
                }
              },
            ),
          );
        },
      ),
      // --- LOGOUT BUTTON END ---

    ],
  );
}