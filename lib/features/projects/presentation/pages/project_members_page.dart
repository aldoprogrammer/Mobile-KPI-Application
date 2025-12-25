import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/add_project_member_usecase.dart';
import '../../domain/usecases/get_project_members_usecase.dart';
import '../providers/project_members_provider.dart';

class ProjectMembersPage extends StatelessWidget {
  const ProjectMembersPage({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectMembersProvider>(
      create: (context) => ProjectMembersProvider(
        getMembers: context.read<GetProjectMembersUseCase>(),
        addMember: context.read<AddProjectMemberUseCase>(),
        projectId: project.id,
      )..load(),
      child: _ProjectMembersView(project: project),
    );
  }
}

class _ProjectMembersView extends StatelessWidget {
  const _ProjectMembersView({required this.project});

  final Project project;

  Future<void> _openAddMemberDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) => Validators.requiredField(value, fieldName: 'Role'),
                ),
              ],
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      final provider = context.read<ProjectMembersProvider>();
      final success = await provider.addMember(
        email: emailController.text.trim(),
        role: roleController.text.trim(),
      );
      if (!context.mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to add member')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => _openAddMemberDialog(context),
          ),
        ],
      ),
      body: Consumer<ProjectMembersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.members.isEmpty) {
            return const LoadingView();
          }
          if (provider.error != null && provider.members.isEmpty) {
            return ErrorView(
              message: provider.error!,
              onRetry: provider.load,
            );
          }
          if (provider.members.isEmpty) {
            return const EmptyView(
              title: 'No members yet',
              subtitle: 'Add team members to collaborate on this project.',
            );
          }
          return RefreshIndicator(
            onRefresh: provider.load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final member = provider.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(member.name.characters.first.toUpperCase()),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                  trailing: Text(member.role),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: provider.members.length,
            ),
          );
        },
      ),
    );
  }
}
