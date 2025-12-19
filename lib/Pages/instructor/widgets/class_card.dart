import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final bool isLive;
  final VoidCallback onStart;

  const ClassCard({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isLive,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFF6A1B9A) : Colors.white, // Deep Purple if live
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? Colors.redAccent : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive) ...[
                      const Icon(Icons.circle, color: Colors.white, size: 8),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isLive ? "LIVE NOW" : "UPCOMING",
                      style: TextStyle(
                        color: isLive ? Colors.white : Colors.grey[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: TextStyle(
                  color: isLive ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$startTime - $endTime",
                style: TextStyle(
                  color: isLive ? Colors.white70 : Colors.grey,
                  fontSize: 12,
                ),
              ),
              if (isLive)
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}