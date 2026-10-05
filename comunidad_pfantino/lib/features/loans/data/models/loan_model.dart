class LoanModel {
  final int? id;
  final String lenderName;
  final String loanNumber;
  final String? memberNumber;
  final String? debtorName;
  final int? defaultBankAccountId;
  final DateTime startDate;
  final DateTime? dueDate;
  final double originalAmount;
  final double currentBalance;
  final double monthlyRate;
  final double? annualRate;
  final int termMonths;
  final double installmentAmount;
  final String modality;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LoanModel({
    this.id,
    required this.lenderName,
    required this.loanNumber,
    this.memberNumber,
    this.debtorName,
    this.defaultBankAccountId,
    required this.startDate,
    this.dueDate,
    required this.originalAmount,
    required this.currentBalance,
    required this.monthlyRate,
    this.annualRate,
    required this.termMonths,
    required this.installmentAmount,
    required this.modality,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      lenderName: json['lender_name'],
      loanNumber: json['loan_number'].toString(),
      memberNumber: json['member_number']?.toString(),
      debtorName: json['debtor_name'],
      defaultBankAccountId: json['default_bank_account_id'],
      startDate: DateTime.parse(json['start_date']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      originalAmount: double.parse(json['original_amount'].toString()),
      currentBalance: double.parse(json['current_balance'].toString()),
      monthlyRate: double.parse(json['monthly_rate'].toString()),
      annualRate: json['annual_rate'] != null ? double.parse(json['annual_rate'].toString()) : null,
      termMonths: json['term_months'] ?? 60,
      installmentAmount: double.parse(json['installment_amount'].toString()),
      modality: json['modality'] ?? 'INTERES_CAPITAL_CUOTA_FIJA',
      status: json['status'] ?? 'active',
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'lender_name': lenderName,
      'loan_number': loanNumber,
      if (memberNumber != null) 'member_number': memberNumber,
      if (debtorName != null) 'debtor_name': debtorName,
      if (defaultBankAccountId != null) 'default_bank_account_id': defaultBankAccountId,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T')[0],
      'original_amount': originalAmount,
      'current_balance': currentBalance,
      'monthly_rate': monthlyRate,
      if (annualRate != null) 'annualRate': annualRate,
      'term_months': termMonths,
      'installment_amount': installmentAmount,
      'modality': modality,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}
