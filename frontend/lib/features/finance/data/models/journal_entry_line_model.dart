import '../../../accounting/data/models/accounting_account_model.dart';
import 'journal_entry_model.dart';

class JournalEntryLineModel {
  final int id;
  final int journalEntryId;
  final int accountId;
  final double debit;
  final double credit;
  final AccountingAccountModel? account;
  final JournalEntryModel? journalEntry;

  JournalEntryLineModel({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    required this.debit,
    required this.credit,
    this.account,
    this.journalEntry,
  });

  factory JournalEntryLineModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryLineModel(
      id: json['id'],
      journalEntryId: json['journal_entry_id'],
      accountId: json['account_id'],
      debit: double.tryParse(json['debit'].toString()) ?? 0.0,
      credit: double.tryParse(json['credit'].toString()) ?? 0.0,
      account: json['account'] != null
          ? AccountingAccountModel.fromJson(json['account'])
          : null,
      journalEntry: json['journal_entry'] != null
          ? JournalEntryModel.fromJson(json['journal_entry'])
          : null,
    );
  }
}
