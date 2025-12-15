import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:jbh_academy/Components/common_app_bar.dart';

class ResumeViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const ResumeViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: title),
      body: const PDF(
        enableSwipe: true,
        swipeHorizontal: false, // Vertical scrolling
        autoSpacing: false,
        pageFling: false,
      ).cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text("Failed to load PDF: $error")),
      ),
    );
  }
}