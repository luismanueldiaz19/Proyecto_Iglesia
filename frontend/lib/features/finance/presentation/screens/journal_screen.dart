import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/church_colors.dart';
import '../../providers/finance_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(financeProvider.notifier).fetchJournalEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);

    return Scaffold(
      backgroundColor: ChurchColors.background,
      appBar: AppBar(
        title: const Text('Diario General', style: TextStyle(color: ChurchColors.black, fontWeight: FontWeight.bold)),
        backgroundColor: ChurchColors.white,
        iconTheme: const IconThemeData(color: ChurchColors.black),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: ChurchColors.lightGrey, height: 1),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)))
              : state.journalEntries.isEmpty
                  ? const Center(child: Text('No hay asientos contables registrados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: state.journalEntries.length,
                      itemBuilder: (context, index) {
                        final entry = state.journalEntries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Asiento #${entry.id}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      entry.date,
                                      style: const TextStyle(color: ChurchColors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(entry.description, style: const TextStyle(fontStyle: FontStyle.italic)),
                                const Divider(height: 24),
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                  },
                                  children: [
                                    const TableRow(
                                      children: [
                                        Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: ChurchColors.grey)),
                                        Text('Débito', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: ChurchColors.grey)),
                                        Text('Crédito', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: ChurchColors.grey)),
                                      ],
                                    ),
                                    const TableRow(children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
                                    ...entry.lines.map((line) {
                                      final isDebit = line.debit > 0;
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: isDebit ? 0 : 16.0, bottom: 8),
                                            child: Text(
                                              line.account?.name ?? 'Cuenta ${line.accountId}',
                                              style: TextStyle(fontWeight: isDebit ? FontWeight.w500 : FontWeight.normal),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              line.debit > 0 ? '\$${line.debit.toStringAsFixed(2)}' : '',
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              line.credit > 0 ? '\$${line.credit.toStringAsFixed(2)}' : '',
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
