class UserProfile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    this.fullName,
    this.phone,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
