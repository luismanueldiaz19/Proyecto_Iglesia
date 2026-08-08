import 'cash_transaction_model.dart';
import 'cash_reconciliation_denomination_model.dart';

class CashReconciliationModel {
  final int id;
  final int moduleId;
  final String date;
  final String status; // 'draft' o 'closed'
  final double totalGeneral;
  final double totalExpenses;
  final double difference;
  final List<CashTransactionModel> transactions;
  final List<CashReconciliationDenominationModel> denominations;
  final bool isDeposited;
  final int? depositAccountId;
  final String? depositDate;
  final double? depositAmount;
  final double? depositDifference;

  CashReconciliationModel({
    required this.id,
    required this.moduleId,
    required this.date,
    required this.status,
    required this.totalGeneral,
    required this.totalExpenses,
    required this.difference,
    required this.transactions,
    this.denominations = const [],
    this.isDeposited = false,
    this.depositAccountId,
    this.depositDate,
    this.depositAmount,
    this.depositDifference,
  });

  factory CashReconciliationModel.fromJson(Map<String, dynamic> json) {
    return CashReconciliationModel(
      id: json['id'],
      moduleId: json['module_id'],
      date: _formatDate(json['date']),
      status: json['status'],
      totalGeneral: double.tryParse(json['total_general'].toString()) ?? 0.0,
      totalExpenses: double.tryParse(json['total_expenses'].toString()) ?? 0.0,
      difference: double.tryParse(json['difference'].toString()) ?? 0.0,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
                .map((t) => CashTransactionModel.fromJson(t))
                .toList()
          : [],
      denominations: json['denominations'] != null
          ? (json['denominations'] as List)
                .map((d) => CashReconciliationDenominationModel.fromJson(d))
                .toList()
          : [],
      isDeposited: json['is_deposited'] ?? false,
      depositAccountId: json['deposit_account_id'],
      depositDate: _formatDate(json['deposit_date']),
      depositAmount: json['deposit_amount'] != null ? double.tryParse(json['deposit_amount'].toString()) : null,
      depositDifference: json['deposit_difference'] != null ? double.tryParse(json['deposit_difference'].toString()) : null,
    );
  }

  static String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final parsed = DateTime.parse(rawDate);
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (e) {
      return rawDate.split('T').first;
    }
  }
}
