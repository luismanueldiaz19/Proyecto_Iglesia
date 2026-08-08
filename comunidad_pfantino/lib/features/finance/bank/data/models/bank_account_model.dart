import 'bank_model.dart';

class BankAccount {
  final int id;
  final int bankId;
  final String name;
  final String accountNumber;
  final String currency;
  final double currentBalance;
  final int? accountingAccountId;
  final bool isActive;
  final Bank? bank;

  BankAccount({
    required this.id,
    required this.bankId,
    required this.name,
    required this.accountNumber,
    required this.currency,
    required this.currentBalance,
    this.accountingAccountId,
    required this.isActive,
    this.bank,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankId: json['bank_id'],
      name: json['name'],
      accountNumber: json['account_number'],
      currency: json['currency'] ?? 'DOP',
      currentBalance: double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0.0,
      accountingAccountId: json['accounting_account_id'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      bank: json['bank'] != null ? Bank.fromJson(json['bank']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_id': bankId,
      'name': name,
      'account_number': accountNumber,
      'currency': currency,
      'current_balance': currentBalance,
      'accounting_account_id': accountingAccountId,
      'is_active': isActive,
    };
  }
}
