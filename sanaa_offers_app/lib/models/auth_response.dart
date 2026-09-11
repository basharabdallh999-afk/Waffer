class AuthResponse {
  const AuthResponse({required this.token, required this.userName});

  final String token;
  final String userName;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: '${json['token'] ?? json['accessToken'] ?? ''}',
      userName: '${json['userName'] ?? json['name'] ?? 'زائر'}',
    );
  }
}