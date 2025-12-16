import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:video_player/video_player.dart';
import '../../Components/common_app_bar.dart';
import '../../Models/lesson_model.dart';

class LessonViewerScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.contentType == 'video') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.lesson.contentUrl));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text("Error: $errorMessage", style: const TextStyle(color: Colors.white)),
          );
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _isError = true);
      debugPrint("Video Error: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title: widget.lesson.title),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    // 1. PDF Viewer
    if (widget.lesson.contentType == 'pdf') {
      return const PDF().cachedFromUrl(
        widget.lesson.contentUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text("Error loading PDF: $error")),
      );
    }

    // 2. Video Player
    else if (widget.lesson.contentType == 'video') {
      if (_isError) return const Center(child: Text("Failed to load video."));

      return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Center(child: Chewie(controller: _chewieController!))
          : const Center(child: CircularProgressIndicator());
    }

    // 3. Unknown Type
    return const Center(child: Text("Unsupported content type"));
  }
}