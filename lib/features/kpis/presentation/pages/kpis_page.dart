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
    );
  }
}
