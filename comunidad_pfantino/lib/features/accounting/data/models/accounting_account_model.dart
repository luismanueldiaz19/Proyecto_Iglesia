class AccountingAccountModel {
  final int id;
  final String code;
  final String name;
  final String type;
  final int? parentId;
  final bool isTransactional;
  
  // Relationship
  final AccountingAccountModel? parent;

  AccountingAccountModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.parentId,
    required this.isTransactional,
    this.parent,
  });

  factory AccountingAccountModel.fromJson(Map<String, dynamic> json) {
    return AccountingAccountModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      type: json['type'],
      parentId: json['parent_id'],
      isTransactional: json['is_transactional'] == 1 || json['is_transactional'] == true,
      parent: json['parent'] != null ? AccountingAccountModel.fromJson(json['parent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'type': type,
      'parent_id': parentId,
      'is_transactional': isTransactional,
    };
  }
}
