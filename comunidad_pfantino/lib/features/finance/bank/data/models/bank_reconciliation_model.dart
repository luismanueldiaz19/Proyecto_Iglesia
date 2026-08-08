import 'bank_account_model.dart';
import 'bank_transaction_model.dart';

class BankReconciliation {
  final int id;
  final int bankAccountId;
  final DateTime statementDate;
  final double statementBalance;
  final int? reconciledBy;
  final String status; // draft, completed
  final String? notes;
  final BankAccount? bankAccount;
  final List<BankTransaction>? transactions;

  BankReconciliation({
    required this.id,
    required this.bankAccountId,
    required this.statementDate,
    required this.statementBalance,
    this.reconciledBy,
    required this.status,
    this.notes,
    this.bankAccount,
    this.transactions,
  });

  factory BankReconciliation.fromJson(Map<String, dynamic> json) {
    return BankReconciliation(
      id: json['id'],
      bankAccountId: json['bank_account_id'],
      statementDate: DateTime.parse(json['statement_date']),
      statementBalance: double.tryParse(json['statement_balance']?.toString() ?? '0') ?? 0.0,
      reconciledBy: json['reconciled_by'],
      status: json['status'] ?? 'draft',
      notes: json['notes'],
      bankAccount: json['bank_account'] != null ? BankAccount.fromJson(json['bank_account']) : null,
      transactions: json['transactions'] != null 
          ? (json['transactions'] as List).map((t) => BankTransaction.fromJson(t)).toList()
          : null,
    );
  }
}
