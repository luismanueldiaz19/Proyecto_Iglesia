import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class GastosTableWidget extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> gastos;

  const GastosTableWidget({
    super.key,
    required this.isLoading,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade50,
                        ),
                        dividerThickness: 0.5,
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                          verticalInside: BorderSide(
                            color: Colors.grey.shade100,
                            width: 0.5,
                          ),
                        ),
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 50,
                        columnSpacing: 16.0,
                        horizontalMargin: 16.0,
                        columns: [
                          DataColumn(
                            label: Text(
                              'FECHA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CONCEPTO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              '#CHEQUE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'MONTO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                        rows: gastos.map((gasto) {
                          final String registeredBy = gasto['user'] != null
                              ? gasto['user']['name']
                              : 'Desconocido';
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  gasto['fecha_gasto']?.toString() ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Tooltip(
                                  message: 'Registrado por: $registeredBy',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width:
                                            constraints.maxWidth *
                                            0.3, // Limit width
                                        child: Text(
                                          gasto['concepto']?.toString() ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey.shade800,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.info_outline,
                                        size: 12,
                                        color: Colors.blueGrey.shade300,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  gasto['num_check']?.toString() ?? '-',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '\$${CurrencyFormatter.formatAmount(double.tryParse(gasto['monto']?.toString() ?? '0') ?? 0.0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
