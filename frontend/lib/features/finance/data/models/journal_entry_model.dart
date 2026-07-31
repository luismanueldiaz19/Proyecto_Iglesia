import 'journal_entry_line_model.dart';

class JournalEntryModel {
  final int id;
  final String date;
  final String description;
  final List<JournalEntryLineModel> lines;

  JournalEntryModel({
    required this.id,
    required this.date,
    required this.description,
    this.lines = const [],
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'],
      date: json['date'],
      description: json['description'],
      lines: json['lines'] != null
          ? (json['lines'] as List).map((l) => JournalEntryLineModel.fromJson(l)).toList()
          : [],
    );
  }
}
