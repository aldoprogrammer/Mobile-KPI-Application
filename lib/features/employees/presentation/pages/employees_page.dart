import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/employees_provider.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesProvider>().loadInitial();
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
      context.read<EmployeesProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      body: Consumer<EmployeesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.employees.isEmpty) {
            return const LoadingView();
          }
          if (provider.error != null && provider.employees.isEmpty) {
            return ErrorView(
              message: provider.error!,
              onRetry: provider.loadInitial,
            );
          }
          if (provider.employees.isEmpty) {
            return const EmptyView(
              title: 'No employees found',
              subtitle: 'Try again later or adjust the paging settings.',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.loadInitial,
            child: ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index >= provider.employees.length) {
                  if (!provider.isLoadingMore) {
                    return const SizedBox.shrink();
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final employee = provider.employees[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(employee.name.characters.first.toUpperCase())),
                  title: Text(employee.name),
                  subtitle: Text(employee.email),
                  trailing: Text(employee.role),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: provider.employees.length + (provider.hasMore ? 1 : 0),
            ),
          );
        },
      ),
    );
  }
}
