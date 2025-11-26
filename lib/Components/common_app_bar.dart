import 'package:flutter/material.dart';

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
      // 4. Wrap each icon in its own separate "clip"

      // Message Icon Clip
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColor, // Solid primary color
          shape: BoxShape.circle, // Make it circular
        ),
        child: IconButton(
          icon: Image.asset(
            'assets/icons/message_icon.png', // <-- Your image path
            width: 22,
            height: 22,
            color: Colors.white, // Color for on-primary background
          ),
          onPressed: () {},
          constraints: const BoxConstraints(), // Remove default padding
          padding: const EdgeInsets.all(8), // Add custom padding
        ),
      ),

      // Notification Icon Clip
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColor, // Solid primary color
          shape: BoxShape.circle, // Make it circular
        ),
        child: IconButton(
          icon: Image.asset(
            'assets/icons/notification_icon.png', // <-- Your image path
            width: 22,
            height: 22,
            color: Colors.white, // Color for on-primary background
          ),
          onPressed: () {},
          constraints: const BoxConstraints(), // Remove default padding
          padding: const EdgeInsets.all(8), // Add custom padding
        ),
      ),

      // Profile picture CircleAvatar remains outside the "clipbar"
      const Padding(
        padding: EdgeInsets.only(right: 16.0, left: 8.0),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,
          // backgroundImage: AssetImage('assets/images/profile_pic.png'),
        ),
      ),
    ],
  );
}