import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/projects_provider.dart';
import 'project_members_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<void> _openCreateProject(BuildContext context) async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final statusController = TextEditingController(text: 'active');
    final formKey = GlobalKey<FormState>();
    DateTime? startDate;
    DateTime? endDate;

    Future<void> pickDate({
      required bool isStart,
    }) async {
      final seeed = isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: seeed,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create project'),
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
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
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
                    TextFormField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await pickDate(isStart: true);
                              setState(() {});
                            },
                            icon: const Icon(Icons.date_range_outlined),
                            label: Text(
                              startDate == null
                                  ? 'Start date'
                                  : '${startDate!.year}-${startDate!.month}-${startDate!.day}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await pickDate(isStart: false);
                              setState(() {});
                            },
                            icon: const Icon(Icons.event_outlined),
                            label: Text(
                              endDate == null
                                  ? 'End date'
                                  : '${endDate!.year}-${endDate!.month}-${endDate!.day}',
                            ),
                          ),
                        ),
                      ],
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
      final provider = context.read<ProjectsProvider>();
      final success = await provider.createProject(
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        status: statusController.text.trim(),
        startDate: startDate?.toUtc().toIso8601String(),
        endDate: endDate?.toUtc().toIso8601String(),
      );
      if (!context.mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create project')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingView();
          }
          if (provider.error != null) {
            return ErrorView(
              message: provider.error!,
              onRetry: provider.load,
            );
          }
          if (provider.projects.isEmpty) {
            return const EmptyView(
              title: 'No projects found',
              subtitle: 'Create a project to start tracking KPI initiatives.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return Card(
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text(project.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectMembersPage(project: project),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: provider.projects.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateProject(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New project'),
      ),
    );
  }
}
