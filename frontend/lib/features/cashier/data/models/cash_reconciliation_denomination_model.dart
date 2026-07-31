import 'denomination_model.dart';

class CashReconciliationDenominationModel {
  final int id;
  final int quantity;
  final double total;
  final DenominationModel denomination;

  CashReconciliationDenominationModel({
    required this.id,
    required this.quantity,
    required this.total,
    required this.denomination,
  });

  factory CashReconciliationDenominationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CashReconciliationDenominationModel(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      denomination: DenominationModel.fromJson(json['denomination']),
    );
  }
}
