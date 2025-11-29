class User {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String? ?? 'User',
      email: json['email'] as String,
      role: json['role'] as String,
      // Use '?? false' to default to false if null
      isEmailVerified: (json['is_email_verified'] as bool?) ?? false,
      isPhoneVerified: (json['is_phone_verified'] as bool?) ?? false,
    );
  }
}

