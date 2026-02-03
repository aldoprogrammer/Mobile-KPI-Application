import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/kpis_provider.dart';

class KpisPage extends StatefulWidget {
  const KpisPage({super.key});

  @override
  State<KpisPage> createState() => _KpisPageState();
}

class _KpisPageState extends State<KpisPage> {
  Future<void> _openCreateKpi(BuildContext context) async {
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int weightValue = 3;
    bool activeValue = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create KPI'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                      validator: (value) =>
                          value == null || value.trim().length < 3 ? 'Min 3 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value == null || value.trim().length < 3 ? 'Min 3 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (optional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: weightValue,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      items: List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Weight ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) => setState(() => weightValue = value ?? 3),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: activeValue,
                      onChanged: (value) => setState(() => activeValue = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
      },
    );

    if (result == true && context.mounted) {
      final provider = context.read<KpisProvider>();
      final success = await provider.createKpi(
        code: codeController.text.trim(),
        title: titleController.text.trim(),
        weight: weightValue,
        description: descriptionController.text.trim(),
        active: activeValue,
      );
      if (!context.mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create KPI')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KPI created')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KpisProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPIs'),
        actions: [
          Consumer<KpisProvider>(
            builder: (context, provider, _) {
              return Switch(
                value: provider.activeOnly,
                onChanged: (value) => provider.load(activeOnly: value),
              );
            },
          ),
        ],
      ),
      body: Consumer<KpisProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingView();
          }
          if (provider.error != null) {
            return ErrorView(
              message: provider.error!,
              onRetry: () => provider.load(activeOnly: provider.activeOnly),
            );
          }
          if (provider.kpis.isEmpty) {
            return const EmptyView(
              title: 'No KPIs yet',
              subtitle: 'Try toggling active KPIs or refresh later.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final kpi = provider.kpis[index];
              return Card(
                child: ListTile(
                  title: Text(kpi.title),
                  subtitle: Text('${kpi.code} • Weight ${kpi.weight}\n${kpi.description}'),
                  trailing: Icon(
                    kpi.active ? Icons.check_circle : Icons.pause_circle,
                    color: kpi.active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: provider.kpis.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateKpi(context),
        icon: const Icon(Icons.add_chart),
        label: const Text('Add KPI'),
      ),
    );
  }
}
