import 'lesson_model.dart';

class Module {
  final int moduleId;
  final String title;
  final int order;
  final List<Lesson> lessons;

  Module({required this.moduleId, required this.title, required this.order, required this.lessons});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleId: json['module_id'],
      title: json['title'],
      order: json['module_order'] ?? 0,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List).map((l) => Lesson.fromJson(l)).toList()
          : [],
    );
  }
}