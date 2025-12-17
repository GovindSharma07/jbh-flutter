import 'module_model.dart';

class Course {
  final int? courseId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final double price;
  final bool isPublished;

  // New Fields for Enrollment Status
  final String? status;
  final DateTime? enrollmentDate;

  // New Field for Syllabus (Nested Data)
  final List<Module>? modules;

  Course({
    this.courseId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.price,
    this.isPublished = false,
    this.status,
    this.enrollmentDate,
    this.modules,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      title: json['title'] ?? 'Untitled Course',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      // Handle numeric conversion safely
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      isPublished: json['is_published'] ?? false,

      // Map flattened enrollment fields
      status: json['status'],
      enrollmentDate: json['enrollment_date'] != null
          ? DateTime.parse(json['enrollment_date'])
          : null,

      // Map nested modules if present
      modules: json['modules'] != null
          ? (json['modules'] as List).map((m) => Module.fromJson(m)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'is_published': isPublished,
    };
  }
}