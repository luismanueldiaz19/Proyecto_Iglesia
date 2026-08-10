import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class DonationsTableWidget extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> donations;
  final Function(int donationId, String donorName)? onPrint;

  const DonationsTableWidget({
    super.key,
    required this.isLoading,
    required this.donations,
    this.onPrint,
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
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
                                'NO. RECIBO',
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
                                'DONANTE',
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
                                'MÉTODO',
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
                            DataColumn(
                              label: Text(
                                'ACCIONES',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                          rows: donations.map((donation) {
                            final String registeredBy = donation['user'] != null
                                ? donation['user']['name']
                                : 'Desconocido';
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    donation['id']?.toString().padLeft(
                                          5,
                                          '0',
                                        ) ??
                                        '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    // Asumiendo formato de fecha de created_at, ej. "2023-10-15T12:00:00" -> recortamos.
                                    donation['created_at']
                                            ?.toString()
                                            .substring(0, 10) ??
                                        '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Tooltip(
                                    message:
                                        'Cédula: ${donation['donor_cedula'] ?? 'N/A'}',
                                    child: Text(
                                      donation['donor_name']?.toString() ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueGrey.shade800,
                                        fontSize: 13,
                                      ),
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
                                              0.2, // Limitar ancho
                                          child: Text(
                                            donation['concept']?.toString() ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.blueGrey.shade800,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
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
                                    donation['payment_method']?.toString() ??
                                        '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${CurrencyFormatter.formatAmount(double.tryParse(donation['amount']?.toString() ?? '0') ?? 0.0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.print, size: 20),
                                    color: Colors.indigo,
                                    tooltip: 'Imprimir Recibo',
                                    onPressed: () {
                                      if (onPrint != null) {
                                        final id =
                                            int.tryParse(
                                              donation['id']?.toString() ?? '',
                                            ) ??
                                            0;
                                        final name =
                                            donation['donor_name']
                                                ?.toString() ??
                                            '';
                                        onPrint!(id, name);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
