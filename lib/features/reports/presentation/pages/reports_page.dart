import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/reports_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      context.read<ReportsProvider>().loadMore();
    }
  }

  Future<void> _openFilter(BuildContext context, ReportsProvider provider) async {
    final employeeController = TextEditingController(text: provider.employeeId ?? '');
    final fromController = TextEditingController(text: provider.from ?? '');
    final toController = TextEditingController(text: provider.to ?? '');

    final apply = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Report filters', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: employeeController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'e.g. 1f312855-2b7e-47d7-8b56-6a9a7a5e2186',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fromController,
                decoration: const InputDecoration(
                  labelText: 'From (ISO)',
                  hintText: '2025-12-01T00:00:00.000Z',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toController,
                decoration: const InputDecoration(
                  labelText: 'To (ISO)',
                  hintText: '2025-12-31T23:59:59.999Z',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (apply == true && mounted) {
      await provider.loadInitial(
        employeeId: employeeController.text.trim().isEmpty
            ? null
            : employeeController.text.trim(),
        from: fromController.text.trim().isEmpty ? null : fromController.text.trim(),
        to: toController.text.trim().isEmpty ? null : toController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          Consumer<ReportsProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _openFilter(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summaries.isEmpty) {
            return const LoadingView();
          }
          if (provider.error != null && provider.summaries.isEmpty) {
            return ErrorView(
              message: provider.error!,
              onRetry: provider.loadInitial,
            );
          }
          if (provider.summaries.isEmpty) {
            return const EmptyView(
              title: 'No reports yet',
              subtitle: 'New summaries will appear as data is available.',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadInitial,
            child: ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index >= provider.summaries.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final summary = provider.summaries[index];
                return Card(
                  child: ListTile(
                    title: Text('Employee ${summary.employeeId}'),
                    subtitle: Text('${summary.periodStart} → ${summary.periodEnd}\n${summary.status}'),
                    trailing: Text(summary.totalScore.toString()),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: provider.summaries.length + (provider.hasMore ? 1 : 0),
            ),
          );
        },
      ),
    );
  }
}
