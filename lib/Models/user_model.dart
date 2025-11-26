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
      isEmailVerified: json['is_email_verified'] as bool,
      isPhoneVerified: json['is_phone_verified'] as bool,
    );
  }
}

// Define the overall authentication state
class AuthState {
  final bool isLoading;
  final User? user;
  final String? token;
  final String? error;
  final String? tempEmail; // Correctly defined field

  AuthState({
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
    this.tempEmail, // Correctly added to the main constructor
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? token,
    String? error,
    String? tempEmail, // Correctly added to copyWith
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
      tempEmail: tempEmail ?? this.tempEmail,
    );
  }

  // Helper methods
  factory AuthState.initial() => AuthState();
  AuthState asAuthenticated(User user, String token) => AuthState(user: user, token: token);
  AuthState asLoading() => AuthState(isLoading: true);
  AuthState asError(String error) => AuthState(error: error);
  AuthState asUnauthenticated({String? tempEmail}) => AuthState(tempEmail: tempEmail);
}