class UserEntity {
  final int? id;
  final String name;
  final String username;
  final String role;

  UserEntity({
    this.id,
    required this.name,
    required this.username,
    required this.role,
  });
}
