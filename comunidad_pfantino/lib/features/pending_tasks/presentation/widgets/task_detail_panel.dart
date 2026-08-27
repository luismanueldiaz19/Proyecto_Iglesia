import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/church_colors.dart';
import '../../data/models/pending_task_model.dart';

class TaskDetailPanel extends StatefulWidget {
  final PendingTaskModel? task;
  final Function(PendingTaskModel) onSave;
  final Function(int) onDelete;
  final VoidCallback onClearSelection;
  final bool isMobile;

  const TaskDetailPanel({
    super.key,
    this.task,
    required this.onSave,
    required this.onDelete,
    required this.onClearSelection,
    this.isMobile = false,
  });

  @override
  State<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _commentsController = TextEditingController();

  DateTime _planDate = DateTime.now();
  DateTime? _completedDate;
  String _status = 'Pendiente';

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  @override
  void didUpdateWidget(covariant TaskDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task?.id != oldWidget.task?.id) {
      _loadTaskData();
    }
  }

  void _loadTaskData() {
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _detailsController.text = widget.task!.details;
      _commentsController.text = widget.task!.comments ?? '';
      _planDate = widget.task!.planDate;
      _completedDate = widget.task!.completedDate;
      _status = widget.task!.status;
    } else {
      _titleController.clear();
      _detailsController.clear();
      _commentsController.clear();
      _planDate = DateTime.now();
      _completedDate = null;
      _status = 'Pendiente';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTask = PendingTaskModel(
        id: widget.task?.id ?? 0,
        title: _titleController.text,
        details: _detailsController.text,
        planDate: _planDate,
        completedDate: _status.toLowerCase() == 'terminado'
            ? (_completedDate ?? DateTime.now())
            : null,
        status: _status,
        comments: _commentsController.text.isNotEmpty
            ? _commentsController.text
            : null,
      );
      widget.onSave(newTask);
      if (widget.task == null) {
        _loadTaskData();
      }
    }
  }

  Widget _buildDateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isReadOnly ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: isReadOnly ? ChurchColors.lightGrey.withValues(alpha: 0.1) : null,
              border: Border.all(color: ChurchColors.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.isMobile ? 16.0 : 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.task == null
                              ? 'Nuevo Registro'
                              : 'Detalle del Registro',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.task != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar'),
                              content: const Text(
                                '¿Estás seguro de eliminar este registro?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            widget.onDelete(widget.task!.id);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onClearSelection,
                        tooltip: 'Cerrar detalle',
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Título',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ej. Proceso de registros',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Detalles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ChurchColors.lightGrey.withValues(
                          alpha: 0.1,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    // Uso de Flex o Row dependiendo del espacio (para móviles Wrap)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: widget.isMobile ? double.infinity : 150,
                          child: _buildDateBox(
                            title: 'Fecha Planificada',
                            value: DateFormat('yyyy-MM-dd').format(_planDate),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _planDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _planDate = date);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: widget.isMobile ? double.infinity : 150,
                          child: _buildDateBox(
                            title: 'Fecha Realizada',
                            value: _completedDate != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(_completedDate!)
                                : '-',
                            isReadOnly: false,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _completedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_completedDate ?? DateTime.now()),
                                );
                                if (time != null) {
                                  setState(() {
                                    _completedDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    _status = 'Terminado'; // Auto change status
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: ChurchColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _status.toLowerCase() == 'terminado'
                              ? 'Terminado'
                              : 'Pendiente',
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Pendiente',
                              child: Text('Pendiente'),
                            ),
                            DropdownMenuItem(
                              value: 'Terminado',
                              child: Text('Terminado'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _status = val;
                                if (val == 'Terminado' &&
                                    _completedDate == null) {
                                  _completedDate = DateTime.now();
                                } else if (val == 'Pendiente') {
                                  _completedDate = null;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (widget.task != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Registrado Por',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ChurchColors.lightGrey.withValues(alpha: 0.1),
                          border: Border.all(color: ChurchColors.lightGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.task!.registeredByName ??
                                    widget.task!.registeredByUsername ??
                                    '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Comentario',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Este campo es adicional para cualquier usuario comentar.',
                        filled: true,
                        fillColor: ChurchColors.lightGrey.withValues(
                          alpha: 0.1,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChurchColors.white,
                  foregroundColor: ChurchColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: ChurchColors.lightGrey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submit,
                child: Text(
                  widget.task == null ? 'Registrar Tarea' : 'Guardar Cambios',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
