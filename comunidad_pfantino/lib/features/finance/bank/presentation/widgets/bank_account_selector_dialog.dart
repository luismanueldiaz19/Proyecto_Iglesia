import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_config.dart';

class BankAccountSelectorDialog extends StatefulWidget {
  const BankAccountSelectorDialog({super.key});

  static Future<int?> show(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (context) => const BankAccountSelectorDialog(),
    );
  }

  @override
  State<BankAccountSelectorDialog> createState() =>
      _BankAccountSelectorDialogState();
}

class _BankAccountSelectorDialogState extends State<BankAccountSelectorDialog> {
  bool _isLoadingBanks = false;
  List<dynamic> _bankAccounts = [];
  int? _selectedBankAccountId;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    setState(() => _isLoadingBanks = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bank-accounts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _bankAccounts = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading bank accounts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBanks = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿A qué cuenta bancaria o caja deseas asignar estos registros importados?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (_isLoadingBanks)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedBankAccountId,
                decoration: InputDecoration(
                  labelText: 'Destino (Cuenta o Caja)',
                  hintText: 'Seleccione una cuenta',
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 2,
                    ),
                  ),
                ),
                items: _bankAccounts.map((account) {
                  final bankName = account['bank'] != null
                      ? account['bank']['name']
                      : 'Banco';
                  final accNum = account['account_number'] ?? '';
                  final suffix = accNum.toString().isNotEmpty
                      ? ' ($accNum)'
                      : '';

                  return DropdownMenuItem<int>(
                    value: account['id'],
                    child: Text(
                      '$bankName - ${account['name']}$suffix',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBankAccountId = value;
                  });
                },
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedBankAccountId == null
                      ? null
                      : () => Navigator.pop(context, _selectedBankAccountId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
