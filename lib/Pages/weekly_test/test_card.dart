
import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget details;
  final Widget? action;
  final bool isLive;
  final Color primaryColor;

  const TestCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.details,
    this.action,
    this.isLive = false,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    // Error builder for placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: -8,
                    left: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Text(
                        '● Live Now',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  details,
                  const SizedBox(height: 8),
                  if (action != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: action,
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