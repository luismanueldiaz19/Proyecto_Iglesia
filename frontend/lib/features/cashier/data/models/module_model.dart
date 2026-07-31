class ModuleModel {
  final int id;
  final String name;
  final bool isActive;

  ModuleModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
