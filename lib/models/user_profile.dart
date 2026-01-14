class UserProfile {
  String name;
  String email;
  int avatarIndex;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarIndex,
  });

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'avatarIndex': avatarIndex};
  }

  // Create from Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarIndex: map['avatarIndex'] ?? 0,
    );
  }
}
