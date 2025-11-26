import 'package:flutter/material.dart';
import 'package:jbh_academy/app_routes.dart'; // <-- 1. Corrected import

class FloatingCustomNavBar extends StatelessWidget {
  // 2. Added currentIndex to know which tab is active
  final int currentIndex;

  const FloatingCustomNavBar({super.key, this.currentIndex = -1});

  @override
  Widget build(BuildContext context) {
    // This is the main container, rounded and colored
    return Container(
      height: 70, // Standard height for a nav bar
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      // Add margin to make it float
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Dark blue from your image
        borderRadius: BorderRadius.circular(35), // Fully rounded ends
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // Soft shadow
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            context: context,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Purchase',
            index: 1,
            context: context,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            index: 2,
            context: context,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.download_outlined,
            label: 'Downloads',
            index: 3,
            context: context,
            currentIndex: currentIndex,
          ),
          _buildNavItem(
            icon: Icons.help_outline,
            label: 'Doubts',
            index: 4,
            context: context,
            currentIndex: currentIndex,
          ),
        ],
      ),
    );
  }

  // Helper widget to build each of the 5 items
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
    required int currentIndex,
  }) {
    // 3. Check if this item is selected
    final bool isSelected = (index == currentIndex);
    // 4. Set color based on selection
    final Color color = isSelected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.7);

    return InkWell(
      // 5. Corrected onTap syntax and completed logic
      onTap: () {
        // Don't do anything if tapping the active screen's icon
        if (isSelected) return;

        switch (index) {
          case 0:
            // Pop back to the home screen
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            break;
          case 1:
            // Pop to home, then push Purchase (Payment Options)
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            Navigator.pushNamed(context, AppRoutes.myCourses);
            break;
          case 2:
            // Pop to home, then push Search (Placeholder)
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            Navigator.pushNamed(
              context,
              AppRoutes.placeholder,
              arguments: {"title": "Search"},
            );
            break;
          case 3:
            // Pop to home, then push Downloads (PDF Notes)
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            Navigator.pushNamed(context, AppRoutes.pdfNotes);
            break;
          case 4:
            // Pop to home, then push Doubts (Placeholder)
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            Navigator.pushNamed(
              context,
              AppRoutes.placeholder,
              arguments: {"title": 'Doubts'},
            );
            break;
        }
      },
      borderRadius: BorderRadius.circular(20), // For the ripple effect
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take up minimal vertical space
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
