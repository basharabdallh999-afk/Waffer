class UserEntity {
  const UserEntity({
    required this.name,
    required this.email,
    this.isMerchant = false,
    this.storeName,
    this.avatarUrl,
    this.token,
    this.isGuest = false,
    this.isApproved = true,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedUntil,
  });

  final String name;
  final String email;
  final bool isMerchant;
  final String? storeName;
  final String? avatarUrl;
  final String? token;
  final bool isGuest;
  final bool isApproved;
  final bool isSuspended;
  final String? suspensionReason;
  final String? suspendedUntil;

  UserEntity copyWith({
    String? name,
    String? email,
    bool? isMerchant,
    String? storeName,
    String? avatarUrl,
    String? token,
    bool? isGuest,
    bool? isApproved,
    bool? isSuspended,
    String? suspensionReason,
    String? suspendedUntil,
  }) {
    return UserEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      isMerchant: isMerchant ?? this.isMerchant,
      storeName: storeName ?? this.storeName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
      isGuest: isGuest ?? this.isGuest,
      isApproved: isApproved ?? this.isApproved,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
    );
  }

  factory UserEntity.guest() {
    return const UserEntity(
      name: 'زائر',
      email: 'guest@waffer.com',
      isMerchant: false,
      isGuest: true,
      isApproved: true,
      isSuspended: false,
    );
  }
}
