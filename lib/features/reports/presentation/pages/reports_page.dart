import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/report_summary.dart';
import '../providers/reports_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ScrollController _controller;

  static const _pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  String _formatDate(BuildContext context, String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    return MaterialLocalizations.of(context).formatMediumDate(local);
  }

  String _formatDateRange(BuildContext context, String start, String end) {
    final startText = _formatDate(context, start);
    final endText = _formatDate(context, end);
    return '$startText - $endText';
  }

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return scheme.tertiary;
      case 'REJECTED':
        return scheme.error;
      case 'SUBMITTED':
        return scheme.primary;
      case 'DRAFT':
        return scheme.outline;
      default:
        return scheme.secondary;
    }
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  Widget _buildHeader(BuildContext context, ReportsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.95),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.assessment_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  provider.summaries.isEmpty
                      ? 'Track monthly scores and approvals'
                      : '${provider.summaries.length} summaries loaded',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ReportSummary summary) {
    final displayName = (summary.employeeName ?? '').trim().isEmpty
        ? 'Employee ${summary.employeeId}'
        : summary.employeeName!.trim();
    final statusColor = _statusColor(context, summary.status);
    final initials = summary.employeeName?.trim().isNotEmpty == true
        ? _initialsFromName(summary.employeeName!.trim())
        : 'ID';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateRange(context, summary.periodStart, summary.periodEnd),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    summary.status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Score',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    summary.totalScore.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              padding: _pagePadding,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context, provider);
                }
                final dataIndex = index - 1;
                if (dataIndex >= provider.summaries.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildSummaryCard(context, provider.summaries[dataIndex]);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: 1 + provider.summaries.length + (provider.hasMore ? 1 : 0),
            ),
          );
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: () => _openFilter(context, provider),
            icon: const Icon(Icons.tune),
            label: const Text('Filters'),
          );
        },
      ),
    );
  }
}
