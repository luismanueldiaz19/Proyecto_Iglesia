import 'bank_account_model.dart';

class BankTransaction {
  final int id;
  final int bankAccountId;
  final DateTime date;
  final String type; // deposit, withdrawal, fee, interest, transfer
  final double amount;
  final String? reference;
  final String? description;
  String status; // pending, transit, reconciled
  final BankAccount? bankAccount;

  BankTransaction({
    required this.id,
    required this.bankAccountId,
    required this.date,
    required this.type,
    required this.amount,
    this.reference,
    this.description,
    required this.status,
    this.bankAccount,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'],
      bankAccountId: json['bank_account_id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      reference: json['reference'],
      description: json['description'],
      status: json['status'],
      bankAccount: json['bank_account'] != null ? BankAccount.fromJson(json['bank_account']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_account_id': bankAccountId,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'type': type,
      'amount': amount,
      'reference': reference,
      'description': description,
      'status': status,
    };
  }
}
