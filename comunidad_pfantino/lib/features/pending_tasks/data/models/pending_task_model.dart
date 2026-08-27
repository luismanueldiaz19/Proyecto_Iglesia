class PendingTaskModel {
  final int id;
  final String title;
  final String details;
  final DateTime planDate;
  final DateTime? completedDate;
  final String status;
  final String? comments;
  final String? registeredByName;
  final String? registeredByUsername;

  PendingTaskModel({
    required this.id,
    required this.title,
    required this.details,
    required this.planDate,
    this.completedDate,
    required this.status,
    this.comments,
    this.registeredByName,
    this.registeredByUsername,
  });

  factory PendingTaskModel.fromJson(Map<String, dynamic> json) {
    return PendingTaskModel(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      planDate: DateTime.parse(json['plan_date']),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      status: json['status'],
      comments: json['comments'],
      registeredByName: json['user']?['name'],
      registeredByUsername: json['user']?['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'details': details,
      'plan_date':
          '${planDate.year}-${planDate.month.toString().padLeft(2, '0')}-${planDate.day.toString().padLeft(2, '0')}',
      'completed_date': completedDate?.toIso8601String(),
      'status': status,
      'comments': comments,
    };
  }
}
