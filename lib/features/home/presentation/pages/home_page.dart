import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../approvals/presentation/pages/approvals_page.dart';
import '../../../employees/presentation/pages/employees_page.dart';
import '../../../evaluations/presentation/pages/evaluations_page.dart';
import '../../../kpis/presentation/pages/kpis_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    _DashboardCard(
                      title: 'Employees',
                      subtitle: 'Directory & roles',
                      icon: Icons.people_outline,
                      accentColor: const Color(0xFF2E7D32),
                      onTap: () => _open(context, const EmployeesPage()),
                    ),
                    _DashboardCard(
                      title: 'KPIs',
                      subtitle: 'Active metrics',
                      icon: Icons.track_changes_outlined,
                      accentColor: const Color(0xFF5E35B1),
                      onTap: () => _open(context, const KpisPage()),
                    ),
                    _DashboardCard(
                      title: 'Reports',
                      subtitle: 'Summary results',
                      icon: Icons.bar_chart_outlined,
                      accentColor: const Color(0xFF1565C0),
                      onTap: () => _open(context, const ReportsPage()),
                    ),
                    _DashboardCard(
                      title: 'Projects',
                      subtitle: 'Teams & members',
                      icon: Icons.folder_open,
                      accentColor: const Color(0xFFEF6C00),
                      onTap: () => _open(context, const ProjectsPage()),
                    ),
                    _DashboardCard(
                      title: 'Evaluations',
                      subtitle: 'Create & submit',
                      icon: Icons.assignment_turned_in_outlined,
                      accentColor: const Color(0xFF00838F),
                      onTap: () => _open(context, const EvaluationsPage()),
                    ),
                    _DashboardCard(
                      title: 'Approvals',
                      subtitle: 'Review requests',
                      icon: Icons.verified_outlined,
                      accentColor: const Color(0xFF6D4C41),
                      onTap: () => _open(context, const ApprovalsPage()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle =
        Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.18),
                colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Icon(icon, color: accentColor),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_rounded, color: accentColor),
                        ],
                      ),
                      const Spacer(),
                      Text(title, style: titleStyle),
                      const SizedBox(height: 6),
                      Text(subtitle, style: subtitleStyle),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          'Explore',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
