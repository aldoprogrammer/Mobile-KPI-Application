import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/approval_detail.dart';
import '../providers/approvals_provider.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  final TextEditingController _approvalIdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _approvalIdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApprovalsProvider>().loadInitial();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ApprovalsProvider>().loadMore();
    }
  }

  Future<void> _loadApproval() async {
    final id = _approvalIdController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an approval ID')),
      );
      return;
    }
    await context.read<ApprovalsProvider>().load(id);
  }

  Future<void> _actOnApproval(String action) async {
    final commentController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${action[0]}${action.substring(1).toLowerCase()} approval'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: 'Comment (optional)'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      final provider = context.read<ApprovalsProvider>();
      final detail = provider.detail;
      if (detail == null) return;
      final response = await provider.act(
        approvalId: detail.id,
        action: action,
        comment: commentController.text.trim(),
      );
      if (!mounted) return;
      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to update approval')),
        );
        return;
      }
      await provider.load(detail.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval ${action.toLowerCase()}d')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: Consumer<ApprovalsProvider>(
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

          return RefreshIndicator(
            onRefresh: () => provider.loadInitial(status: provider.status),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Text('Approvals', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.status == null,
                      onSelected: (_) => provider.loadInitial(),
                    ),
                    FilterChip(
                      label: const Text('Submitted'),
                      selected: provider.status == 'SUBMITTED',
                      onSelected: (_) => provider.loadInitial(status: 'SUBMITTED'),
                    ),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: provider.status == 'APPROVED',
                      onSelected: (_) => provider.loadInitial(status: 'APPROVED'),
                    ),
                    FilterChip(
                      label: const Text('Rejected'),
                      selected: provider.status == 'REJECTED',
                      onSelected: (_) => provider.loadInitial(status: 'REJECTED'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...provider.summaries.map(
                  (summary) => Card(
                    child: ListTile(
                      title: Text(summary.employeeName ?? 'Employee ${summary.employeeId ?? '-'}'),
                      subtitle: Text(
                        '${summary.status} • ${summary.currentStep}\n${summary.periodStart ?? '-'} - ${summary.periodEnd ?? '-'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await provider.load(summary.id);
                        if (!context.mounted || provider.detail == null) return;
                        await showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: SingleChildScrollView(
                                child: _ApprovalDetailCard(
                                  detail: provider.detail!,
                                  onApprove: () => _actOnApproval('APPROVE'),
                                  onReject: () => _actOnApproval('REJECT'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                if (provider.hasMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('Lookup by ID'),
                  children: [
                    TextField(
                      controller: _approvalIdController,
                      decoration: const InputDecoration(labelText: 'Approval ID'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.isLoading ? null : _loadApproval,
                      child: const Text('Load approval'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ApprovalDetailCard extends StatelessWidget {
  const _ApprovalDetailCard({
    required this.detail,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalDetail detail;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approval detail', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Status: ${detail.status}'),
            Text('Current step: ${detail.currentStep}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Steps', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...detail.steps.map(
              (step) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${step.step} • ${step.action}'),
                subtitle: Text('${step.actedByEmail} (${step.actedByRole})'),
                trailing: Text(step.createdAt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
