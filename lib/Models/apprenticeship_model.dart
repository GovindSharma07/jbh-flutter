class Apprenticeship {
  final int apprenticeshipId;
  final String companyName;
  final String imageUrl;
  final String title;
  final String description;
  final String location;
  final String stipend;
  final DateTime postedAt;

  Apprenticeship({
    required this.apprenticeshipId,
    required this.companyName,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.location,
    required this.stipend,
    required this.postedAt,
  });

  factory Apprenticeship.fromJson(Map<String, dynamic> json) {
    return Apprenticeship(
      apprenticeshipId: json['apprenticeship_id'],
      companyName: json['company_name'],
      imageUrl: json['image_url'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      stipend: json['stipend'].toString(), // Handle Decimal as string
      postedAt: DateTime.parse(json['posted_at']),
    );
  }
}