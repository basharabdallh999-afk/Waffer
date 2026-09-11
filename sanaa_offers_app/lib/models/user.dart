class UserModel {
  const UserModel({
    required this.name,
    required this.email,
    this.isMerchant = false,
    this.storeName,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final bool isMerchant;
  final String? storeName;
  final String? avatarUrl;

  UserModel copyWith({
    String? name,
    String? email,
    bool? isMerchant,
    String? storeName,
    String? avatarUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      isMerchant: isMerchant ?? this.isMerchant,
      storeName: storeName ?? this.storeName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      name: 'زائر',
      email: 'guest@waffer.com',
      isMerchant: false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: '${json['name'] ?? json['userName'] ?? 'زائر'}',
      email: '${json['email'] ?? 'guest@waffer.com'}',
      isMerchant: json['isMerchant'] == true,
      storeName: json['storeName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'isMerchant': isMerchant,
      'storeName': storeName,
      'avatarUrl': avatarUrl,
    };
  }
}
