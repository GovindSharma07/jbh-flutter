class Resume {
  final int id;
  final String name;
  final String fileUrl;

  Resume({required this.id, required this.name, required this.fileUrl});

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['resume_id'],
      name: json['name'],
      fileUrl: json['file_url'],
    );
  }
}