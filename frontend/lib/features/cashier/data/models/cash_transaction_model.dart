class CashTransactionModel {
  final int id;
  final int cashReconciliationId;
  final int accountId;
  final String description;
  final double amount;
  final String type; // 'income' o 'expense'

  CashTransactionModel({
    required this.id,
    required this.cashReconciliationId,
    required this.accountId,
    required this.description,
    required this.amount,
    required this.type,
  });

  factory CashTransactionModel.fromJson(Map<String, dynamic> json) {
    return CashTransactionModel(
      id: json['id'],
      cashReconciliationId: json['cash_reconciliation_id'],
      accountId: json['account_id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
    );
  }
}
