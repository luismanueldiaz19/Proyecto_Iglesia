import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/church_colors.dart';
import '../../data/models/loan_model.dart';
import '../../providers/loan_provider.dart';

import '../widgets/loan_payment_dialog.dart';

class LoanDetailsScreen extends ConsumerWidget {
  final LoanModel loan;

  const LoanDetailsScreen({super.key, required this.loan});

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoanPaymentDialog(loan: loan),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanDetailsAsync = ref.watch(loanDetailsProvider(loan.id!));
    final formatCurrency = NumberFormat.simpleCurrency(name: '');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalles del Préstamo'),
        backgroundColor: Colors.white,
        foregroundColor: ChurchColors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentDialog(context),
        backgroundColor: ChurchColors.primary,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Aplicar Pago', style: TextStyle(color: Colors.white)),
      ),
      body: loanDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => ref.refresh(loanDetailsProvider(loan.id!)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (data) {
          final transactions = (data['transactions'] as List<dynamic>?) ?? [];
          final installments = (data['installments'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(data, formatCurrency),
                const SizedBox(height: 24),
                
                if (transactions.isNotEmpty) ...[
                  const Text(
                    'Historial de Pagos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ChurchColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionsList(transactions, formatCurrency),
                  const SizedBox(height: 24),
                ],

                if (installments.isNotEmpty) ...[
                  const Text(
                    'Plan de Cuotas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ChurchColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstallmentsList(installments, formatCurrency),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> data, NumberFormat formatCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['lender_name'] ?? 'Prestamista',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ChurchColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Balance Actual', '\$${formatCurrency.format(double.tryParse(data['current_balance'].toString()) ?? 0)}'),
              _buildInfoColumn('Monto Original', '\$${formatCurrency.format(double.tryParse(data['original_amount'].toString()) ?? 0)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Cuota Mensual', '\$${formatCurrency.format(double.tryParse(data['installment_amount'].toString()) ?? 0)}'),
              _buildInfoColumn('Tasa', '${data['monthly_rate']}% / mes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<dynamic> transactions, NumberFormat formatCurrency) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final dateStr = tx['transaction_date'] ?? tx['created_at'];
        final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
        final amount = double.tryParse(tx['total_paid']?.toString() ?? '0') ?? 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.payment, color: Colors.green.shade700),
            ),
            title: Text(
              tx['concept'] ?? 'Pago recibido',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Text(
              '+\$${formatCurrency.format(amount)}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstallmentsList(List<dynamic> installments, NumberFormat formatCurrency) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: installments.length,
      itemBuilder: (context, index) {
        final inst = installments[index];
        final amountDue = double.tryParse(inst['amount_due'].toString()) ?? 0;
        final dueDateStr = inst['due_date'];
        final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;
        final status = inst['status'] ?? 'pending';
        
        final isPaid = status == 'paid';
        
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
              child: Text(
                '${inst['installment_number'] ?? (index + 1)}',
                style: TextStyle(
                  color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Cuota ${inst['installment_number'] ?? (index + 1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              dueDate != null ? 'Vence: ${DateFormat('dd/MM/yyyy').format(dueDate)}' : '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${formatCurrency.format(amountDue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isPaid ? 'Pagado' : 'Pendiente',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
