class Course {
  final int? courseId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final double price;

  Course({
    this.courseId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.price,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      // Handle price being string or number from API
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'price': price,
    };
  }
}