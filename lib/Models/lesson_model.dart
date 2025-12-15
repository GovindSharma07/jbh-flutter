class Lesson {
  final int lessonId;
  final String title;
  final String contentUrl;
  final String contentType;
  final bool isFree;
  final int? duration;

  Lesson({
    required this.lessonId,
    required this.title,
    required this.contentUrl,
    required this.contentType,
    required this.isFree,
    this.duration,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'],
      title: json['title'],
      contentUrl: json['content_url'],
      contentType: json['content_type'] ?? 'video',
      isFree: json['is_free'] ?? false,
      duration: json['duration'],
    );
  }
}