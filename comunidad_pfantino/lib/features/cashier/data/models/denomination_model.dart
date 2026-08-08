class DenominationModel {
  final int id;
  final double value;
  final String type; // 'bill' o 'coin'
  final String currency;

  DenominationModel({
    required this.id,
    required this.value,
    required this.type,
    required this.currency,
  });

  factory DenominationModel.fromJson(Map<String, dynamic> json) {
    return DenominationModel(
      id: json['id'],
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      type: json['type'],
      currency: json['currency'] ?? 'DOP',
    );
  }
}
