import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../../core/presentation/widgets/page_header.dart';
import '../../../../../core/presentation/widgets/primary_button.dart';
import '../../../../../core/theme/church_colors.dart';
import '../../../../../core/utils/app_date_picker.dart';
import '../../../../../core/utils/app_formatters.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/bank_transaction_model.dart';
import '../../data/repositories/bank_repository.dart';
import '../widgets/bank_transaction_form_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class BankAccountDetailScreen extends ConsumerStatefulWidget {
  final int accountId;

  const BankAccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<BankAccountDetailScreen> createState() =>
      _BankAccountDetailScreenState();
}

class _BankAccountDetailScreenState
    extends ConsumerState<BankAccountDetailScreen> {
  final BankRepository _repository = BankRepository();
  bool _isLoading = true;
  BankAccount? _account;
  List<BankTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final account = await _repository.getBankAccountDetails(widget.accountId);
      final transactions = await _repository.getTransactionsForAccount(
        widget.accountId,
      );

      setState(() {
        _account = account;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar detalles: $e')));
      }
    }
  }

  Future<void> _showDownloadStatementDialog() async {
    final now = DateTime.now();
    DateTimeRange? picked = await AppDatePicker.showRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );

    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        final url = await _repository.getStatementPdfUrl(
          widget.accountId,
          picked.start,
          picked.end,
        );
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo abrir el PDF.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider.notifier).currentUser?.role;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isAllowed =
        userRole == 'Operativo' ||
        userRole == 'Administrador' ||
        userRole == 'admin' ||
        userRole == 'Supervisor';
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_account == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Cuenta no encontrada')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/bank/accounts'),
                  ),
                ),
                Expanded(
                  child: PageHeader(
                    title: _account!.name,
                    subtitle:
                        '${_account!.bank?.name ?? 'Banco'} • ${_account!.accountNumber}',
                    actionButton: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAllowed)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: ChurchColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: ChurchColors.primary,
                              ),
                              tooltip: 'Descargar Estado de Cuenta',
                              onPressed: _showDownloadStatementDialog,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),
            _buildBalanceCard(isAllowed),
            SizedBox(height: isMobile ? 16 : 24),
            const Text(
              'Transacciones Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChurchColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _transactions.isEmpty
                    ? const Center(child: Text('No hay transacciones.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          final isDeposit = tx.amount >= 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDeposit
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeposit
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isDeposit
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description ?? tx.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${AppFormatters.date.format(tx.date)} • Ref: ${tx.reference ?? 'N/A'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppFormatters.currency.format(
                                        tx.amount.abs(),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isDeposit
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildStatusBadge(tx.status),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isAllowed) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF1E1E1E),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _account!.currentBalance < 0
                                    ? const Color(0xFF8A1F1F)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              AppFormatters.currency
                                  .format(_account!.currentBalance)
                                  .replaceAll('\$', ''),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: _account!.currentBalance < 0
                                    ? const Color(0xFF8A1F1F)
                                    : const Color(0xFF2E7D32),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isAllowed) const SizedBox(height: 16),
          if (isAllowed)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => BankTransactionFormDialog(
                          bankAccountId: widget.accountId,
                        ),
                      );
                      if (result == true) {
                        _loadData();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Nueva Entrada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChurchColors.primary,
                      foregroundColor: ChurchColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/bank/accounts/${_account!.id}/reconcile');
                    },
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text(
                      'Conciliar Cuenta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChurchColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: ChurchColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    }

    final balanceContainer = Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ChurchColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: ChurchColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Saldo Actual',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ChurchColors.primary,
                  ),
                ),
                Text(
                  AppFormatters.currency
                      .format(_account!.currentBalance)
                      .replaceAll('\$', ''),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ChurchColors.primary,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final actionsContainer = Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isAllowed) ...[
            PrimaryButton(
              text: 'Nueva Transacción',
              icon: Icons.add,
              isOutlined: true,
              width: double.infinity,
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => BankTransactionFormDialog(
                    bankAccountId: widget.accountId,
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Conciliar Cuenta',
              icon: Icons.fact_check,
              isOutlined: false,
              width: double.infinity,
              onPressed: () {
                context.go('/bank/accounts/${_account!.id}/reconcile');
              },
            ),
          ],
        ],
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: balanceContainer),
          if (isAllowed) const SizedBox(width: 24),
          if (isAllowed) Expanded(flex: 2, child: actionsContainer),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'reconciled':
        bgColor = Colors.green.shade50;
        textColor = Colors.green;
        text = 'Conciliado';
        break;
      case 'transit':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange;
        text = 'En Tránsito';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
