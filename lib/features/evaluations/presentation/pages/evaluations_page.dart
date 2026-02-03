import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../kpis/presentation/providers/kpis_provider.dart';
import '../../domain/entities/evaluation_detail.dart';
import '../providers/evaluations_provider.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  final Map<String, int> _scores = {};
  final Map<String, TextEditingController> _comments = {};
  String? _employeeId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesProvider>().loadInitial();
      context.read<KpisProvider>().load(activeOnly: true);
    });
  }

  @override
  void dispose() {
    for (final controller in _comments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return 'Pick date';
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createEvaluation() async {
    final employeesProvider = context.read<EmployeesProvider>();
    final kpisProvider = context.read<KpisProvider>();
    final evaluationProvider = context.read<EvaluationsProvider>();

    if (_employeeId == null || _employeeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an employee')),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a period start and end date')),
      );
      return;
    }
    if (kpisProvider.kpis.isEmpty) {
      await kpisProvider.load(activeOnly: true);
    }

    final items = <Map<String, dynamic>>[];
    for (final kpi in kpisProvider.kpis) {
      final score = _scores[kpi.id];
      if (score != null) {
        items.add({
          'kpiId': kpi.id,
          'score': score,
          'comment': _comments[kpi.id]?.text.trim().isEmpty == true
              ? null
              : _comments[kpi.id]?.text.trim(),
        });
      }
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one KPI score')),
      );
      return;
    }

    final result = await evaluationProvider.create(
      employeeId: _employeeId!,
      periodStart: _startDate!.toUtc().toIso8601String(),
      periodEnd: _endDate!.toUtc().toIso8601String(),
      items: items,
    );
    if (!mounted || result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(evaluationProvider.error ?? 'Failed to create evaluation')),
      );
      return;
    }

    await evaluationProvider.load(result.id);
    if (!mounted) return;
    String employeeName = 'employee';
    for (final employee in employeesProvider.employees) {
      if (employee.id == _employeeId) {
        employeeName = employee.name;
        break;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created evaluation for $employeeName')),
    );
  }

  Future<void> _submitEvaluation(EvaluationDetail detail) async {
    final provider = context.read<EvaluationsProvider>();
    final result = await provider.submit(detail.id);
    if (!mounted || result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to submit evaluation')),
      );
      return;
    }
    await provider.load(detail.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitted. Approval ID: ${result.approvalId}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesProvider = context.watch<EmployeesProvider>();
    final kpisProvider = context.watch<KpisProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluations')),
      body: Consumer<EvaluationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.detail == null) {
            return const LoadingView();
          }
          if (provider.error != null && provider.detail == null) {
            return ErrorView(
              message: provider.error!,
              onRetry: () {
                if (provider.detail != null) {
                  provider.load(provider.detail!.id);
                }
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Create evaluation', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (employeesProvider.isLoading && employeesProvider.employees.isEmpty)
                const LinearProgressIndicator(),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _employeeId,
                items: employeesProvider.employees
                    .map(
                      (employee) => DropdownMenuItem(
                        value: employee.id,
                        child: Text('${employee.name} (${employee.role})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _employeeId = value),
                decoration: const InputDecoration(labelText: 'Employee'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(_formatDate(context, _startDate)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(_formatDate(context, _endDate)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('KPI scores', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (kpisProvider.isLoading && kpisProvider.kpis.isEmpty)
                const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ...kpisProvider.kpis.map((kpi) {
                _comments.putIfAbsent(kpi.id, () => TextEditingController());
                return Card(
                  child: ExpansionTile(
                    title: Text(kpi.title),
                    subtitle: Text('${kpi.code} • Weight ${kpi.weight}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              initialValue: _scores[kpi.id],
                              decoration: const InputDecoration(labelText: 'Score (1-5)'),
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('${index + 1}'),
                                ),
                              ),
                              onChanged: (value) => setState(() => _scores[kpi.id] = value ?? 1),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _comments[kpi.id],
                              decoration: const InputDecoration(labelText: 'Comment (optional)'),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.isLoading ? null : _createEvaluation,
                child: const Text('Create evaluation'),
              ),
              if (provider.detail != null) ...[
                const SizedBox(height: 24),
                _EvaluationDetailCard(
                  detail: provider.detail!,
                  onSubmit: provider.detail!.status == 'DRAFT'
                      ? () => _submitEvaluation(provider.detail!)
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EvaluationDetailCard extends StatelessWidget {
  const _EvaluationDetailCard({required this.detail, this.onSubmit});

  final EvaluationDetail detail;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest evaluation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Employee: ${detail.employeeName}'),
            Text('Status: ${detail.status}'),
            Text('Period: ${detail.periodStart} - ${detail.periodEnd}'),
            if (detail.approvalId != null) Text('Approval ID: ${detail.approvalId}'),
            const SizedBox(height: 12),
            if (onSubmit != null)
              FilledButton(
                onPressed: onSubmit,
                child: const Text('Submit for approval'),
              ),
          ],
        ),
      ),
    );
  }
}
