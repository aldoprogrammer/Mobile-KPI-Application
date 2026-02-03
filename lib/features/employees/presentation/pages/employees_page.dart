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

  Future<void> _openCreateEmployee(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final departmentController = TextEditingController();
    final positionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String roleValue = 'staff';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create employee'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || !value.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) =>
                          value != null && value.length >= 8 ? null : 'Min 8 characters',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: roleValue,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'staff', child: Text('Staff')),
                        DropdownMenuItem(value: 'lead', child: Text('Lead')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) => setState(() => roleValue = value ?? 'staff'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: departmentController,
                      decoration: const InputDecoration(labelText: 'Department (optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: positionController,
                      decoration: const InputDecoration(labelText: 'Position (optional)'),
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
      final provider = context.read<EmployeesProvider>();
      final success = await provider.createEmployee(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: roleValue,
        name: nameController.text.trim(),
        department: departmentController.text.trim(),
        position: positionController.text.trim(),
      );
      if (!context.mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create employee')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee created')),
        );
      }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateEmployee(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add'),
      ),
    );
  }
}
