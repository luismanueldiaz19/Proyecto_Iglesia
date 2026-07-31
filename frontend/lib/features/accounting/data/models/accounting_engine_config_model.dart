import 'accounting_account_model.dart';

class AccountingEngineConfigModel {
  final int id;
  final String operationCode;
  final String name;
  final int debitAccountId;
  final int creditAccountId;
  final int? taxAccountId;
  final double taxPercentage;

  // Relaciones
  final AccountingAccountModel? debitAccount;
  final AccountingAccountModel? creditAccount;
  final AccountingAccountModel? taxAccount;

  AccountingEngineConfigModel({
    required this.id,
    required this.operationCode,
    required this.name,
    required this.debitAccountId,
    required this.creditAccountId,
    this.taxAccountId,
    required this.taxPercentage,
    this.debitAccount,
    this.creditAccount,
    this.taxAccount,
  });

  factory AccountingEngineConfigModel.fromJson(Map<String, dynamic> json) {
    return AccountingEngineConfigModel(
      id: json['id'],
      operationCode: json['operation_code'],
      name: json['name'],
      debitAccountId: json['debit_account_id'],
      creditAccountId: json['credit_account_id'],
      taxAccountId: json['tax_account_id'],
      taxPercentage: double.tryParse(json['tax_percentage'].toString()) ?? 0.0,
      debitAccount: json['debit_account'] != null ? AccountingAccountModel.fromJson(json['debit_account']) : null,
      creditAccount: json['credit_account'] != null ? AccountingAccountModel.fromJson(json['credit_account']) : null,
      taxAccount: json['tax_account'] != null ? AccountingAccountModel.fromJson(json['tax_account']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation_code': operationCode,
      'name': name,
      'debit_account_id': debitAccountId,
      'credit_account_id': creditAccountId,
      'tax_account_id': taxAccountId,
      'tax_percentage': taxPercentage,
    };
  }
}
