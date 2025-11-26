// Widget for an Upcoming Lecture Card
import 'package:flutter/material.dart';

class UpcomingLectureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;
  final String time;
  final String instructor;
  final String reminderTime;
  final Color primaryColor;

  const UpcomingLectureCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.time,
    required this.instructor,
    required this.reminderTime,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date $date',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    instructor,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Handle Set Reminder
                        },
                        icon: Icon(Icons.notifications,
                            size: 18, color: primaryColor),
                        label: Text(
                          'Set Reminder',
                          style: TextStyle(color: primaryColor, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          // This stops the text from growing larger than its font size
                          fit: BoxFit.scaleDown,
                          // This keeps the text aligned to the left
                          alignment: Alignment.centerLeft,
                          child: Text(
                            reminderTime,
                            style: const TextStyle(
                                color: Colors.green, // Or a suitable accent color
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1, // Ensures text is on one line
                          ),
                        ),
                      ),
                    ],
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