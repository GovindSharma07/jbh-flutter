import 'package:flutter/material.dart';

class LiveLectureCard extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String instructor;
  final VoidCallback onJoin; // <--- The function to run when clicked

  const LiveLectureCard({
    Key? key,
    required this.primaryColor,
    required this.title,
    required this.instructor,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 1. "LIVE" Indicator Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/lecture_image.png', // Ensure this asset exists
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                    ),
                    child: const Text(
                      '● LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // 2. Class Info & Join Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('By $instructor', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),

                  // 3. THE JOIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onJoin, // <--- Calls the function passed from parent
                      icon: const Icon(Icons.videocam, size: 18),
                      label: const Text("Join Class"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red for urgency/live
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}