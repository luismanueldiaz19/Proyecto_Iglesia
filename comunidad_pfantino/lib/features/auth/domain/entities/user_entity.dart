class UserEntity {
  final int? id;
  final String name;
  final String username;
  final String role;
  final String? profilePhotoUrl;

  UserEntity({
    this.id,
    required this.name,
    required this.username,
    required this.role,
    this.profilePhotoUrl,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? username,
    String? role,
    String? profilePhotoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
