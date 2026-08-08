class DonationModel {
  final int id;
  final String donorName;
  final String? donorPhone;
  final String? donorCedula;
  final String? donorRnc;
  final bool withReceipt;
  final String paymentMethod;
  final String concept;
  final double amount;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.donorName,
    this.donorPhone,
    this.donorCedula,
    this.donorRnc,
    required this.withReceipt,
    required this.paymentMethod,
    required this.concept,
    required this.amount,
    required this.createdAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'],
      donorName: json['donor_name'],
      donorPhone: json['donor_phone'],
      donorCedula: json['donor_cedula'],
      donorRnc: json['donor_rnc'],
      withReceipt: json['with_receipt'] == 1 || json['with_receipt'] == true,
      paymentMethod: json['payment_method'] ?? 'Efectivo',
      concept: json['concept'],
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
