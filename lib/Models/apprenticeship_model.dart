class Apprenticeship {
  final int id;
  final String title;
  final String companyName;
  final String imageUrl;
  final String location;
  final String description;
  final String duration;
  final String? applicationStatus; // 'pending', 'accepted', etc., or null if not applied
  final bool hasApplied;

  Apprenticeship({
    required this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.duration,
    this.applicationStatus,
    this.hasApplied = false,
  });

  factory Apprenticeship.fromJson(Map<String, dynamic> json) {
    return Apprenticeship(
      id: json['apprenticeship_id'],
      title: json['title'],
      companyName: json['company_name'],
      imageUrl: json['image_url'] ?? '',
      location: json['location'],
      description: json['description'],
      duration: json['duration'] ?? 'N/A',
      applicationStatus: json['application_status'],
      hasApplied: json['has_applied'] ?? false,
    );
  }
}