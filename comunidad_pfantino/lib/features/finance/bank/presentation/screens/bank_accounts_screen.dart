import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/app_formatters.dart';
import '../../../../../core/presentation/widgets/page_header.dart';
import '../../../../../core/theme/church_colors.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/repositories/bank_repository.dart';
import '../widgets/bank_account_form_dialog.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final BankRepository _repository = BankRepository();
  bool _isLoading = true;
  List<BankAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _repository.getBankAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar cuentas: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Cuentas Bancarias',
              subtitle: 'Gestiona los saldos y conciliaciones de tus cuentas',
              actionButton: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => const BankAccountFormDialog(),
                  );
                  if (result == true) {
                    _loadAccounts();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Cuenta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChurchColors.primary,
                  foregroundColor: ChurchColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _accounts.isEmpty
                  ? const Center(
                      child: Text('No hay cuentas bancarias registradas.'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 260, // Altura fija garantizada
                          ),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        return _HoverableAccountCard(account: account);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // El _buildAccountCard anterior ha sido extraído al widget _HoverableAccountCard debajo.
}

class _HoverableAccountCard extends StatefulWidget {
  final BankAccount account;

  const _HoverableAccountCard({required this.account});

  @override
  State<_HoverableAccountCard> createState() => _HoverableAccountCardState();
}

class _HoverableAccountCardState extends State<_HoverableAccountCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isHovered ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack, // Da un pequeño efecto de rebote
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 32 : 24,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHover: (val) => setState(() => _isHovered = val),
            onHighlightChanged: (val) => setState(() => _isHovered = val),
            onTap: () {
              context.go('/bank/accounts/${widget.account.id}');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: ChurchColors.primary,
                        size: 36,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.account.isActive
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.account.isActive ? 'Activa' : 'Inactiva',
                          style: TextStyle(
                            color: widget.account.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.account.name,
                    style: const TextStyle(
                      // fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.bank?.name ?? 'Banco',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '# ${widget.account.accountNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 16),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '\$ ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ChurchColors.primary,
                            ),
                          ),
                          Text(
                            AppFormatters.currency
                                .format(widget.account.currentBalance)
                                .replaceAll('\$', ''),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: ChurchColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
