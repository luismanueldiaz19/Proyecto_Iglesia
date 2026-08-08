class Bank {
  final int id;
  final String name;
  final String? code;
  final bool isActive;

  Bank({
    required this.id,
    required this.name,
    this.code,
    required this.isActive,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
    };
  }
}
