import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_config.dart';
import 'core/network/api_client.dart';
import 'core/network/token_storage.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_session_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/employees/data/datasources/employees_remote_data_source.dart';
import 'features/employees/data/repositories/employees_repository_impl.dart';
import 'features/employees/domain/repositories/employees_repository.dart';
import 'features/employees/domain/usecases/create_employee_usecase.dart';
import 'features/employees/domain/usecases/get_employees_usecase.dart';
import 'features/employees/presentation/providers/employees_provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/kpis/data/datasources/kpis_remote_data_source.dart';
import 'features/kpis/data/repositories/kpis_repository_impl.dart';
import 'features/kpis/domain/repositories/kpis_repository.dart';
import 'features/kpis/domain/usecases/create_kpi_usecase.dart';
import 'features/kpis/domain/usecases/get_active_kpis_usecase.dart';
import 'features/kpis/domain/usecases/get_kpis_usecase.dart';
import 'features/kpis/presentation/providers/kpis_provider.dart';
import 'features/projects/data/datasources/projects_remote_data_source.dart';
import 'features/projects/data/repositories/projects_repository_impl.dart';
import 'features/projects/domain/repositories/projects_repository.dart';
import 'features/projects/domain/usecases/add_project_member_usecase.dart';
import 'features/projects/domain/usecases/create_project_usecase.dart';
import 'features/projects/domain/usecases/get_project_members_usecase.dart';
import 'features/projects/domain/usecases/get_projects_usecase.dart';
import 'features/projects/presentation/providers/projects_provider.dart';
import 'features/reports/data/datasources/reports_remote_data_source.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/domain/usecases/get_report_summaries_usecase.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/evaluations/data/datasources/evaluations_remote_data_source.dart';
import 'features/evaluations/data/repositories/evaluations_repository_impl.dart';
import 'features/evaluations/domain/repositories/evaluations_repository.dart';
import 'features/evaluations/domain/usecases/create_evaluation_usecase.dart';
import 'features/evaluations/domain/usecases/get_evaluation_usecase.dart';
import 'features/evaluations/domain/usecases/submit_evaluation_usecase.dart';
import 'features/evaluations/presentation/providers/evaluations_provider.dart';
import 'features/approvals/data/datasources/approvals_remote_data_source.dart';
import 'features/approvals/data/repositories/approvals_repository_impl.dart';
import 'features/approvals/domain/repositories/approvals_repository.dart';
import 'features/approvals/domain/usecases/act_on_approval_usecase.dart';
import 'features/approvals/domain/usecases/get_approval_usecase.dart';
import 'features/approvals/domain/usecases/get_approvals_usecase.dart';
import 'features/approvals/presentation/providers/approvals_provider.dart';

void main() {
  ApiConfig.useEnvironment(AppEnvironment.dev);
  runApp(const AppBootstrap());
}

class SessionExpiredHandler {
  VoidCallback? onExpired;

  void handle() => onExpired?.call();
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final TokenStorage _tokenStorage;
  late final SessionExpiredHandler _sessionHandler;
  late final ApiClient _apiClient;
  late final AuthRefreshService _refreshService;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _sessionHandler = SessionExpiredHandler();
    _refreshService = AuthRefreshService();
    _apiClient = ApiClient(
      tokenStorage: _tokenStorage,
      tokenRefresher: _refreshService,
      onSessionExpired: _sessionHandler.handle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: _tokenStorage),
        Provider<ApiClient>.value(value: _apiClient),
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<AuthLocalDataSource>(
          create: (context) =>
              AuthLocalDataSource(context.read<TokenStorage>()),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remote: context.read<AuthRemoteDataSource>(),
            local: context.read<AuthLocalDataSource>(),
          ),
        ),
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(context.read<AuthRepository>()),
        ),
        Provider<GetSessionUseCase>(
          create: (context) =>
              GetSessionUseCase(context.read<AuthRepository>()),
        ),
        Provider<LogoutUseCase>(
          create: (context) => LogoutUseCase(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final provider = AuthProvider(
              loginUseCase: context.read<LoginUseCase>(),
              getSessionUseCase: context.read<GetSessionUseCase>(),
              logoutUseCase: context.read<LogoutUseCase>(),
            );
            _sessionHandler.onExpired = provider.forceLogout;
            provider.initialize();
            return provider;
          },
        ),
        Provider<EmployeesRemoteDataSource>(
          create: (context) =>
              EmployeesRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<EmployeesRepository>(
          create: (context) => EmployeesRepositoryImpl(
            context.read<EmployeesRemoteDataSource>(),
          ),
        ),
        Provider<GetEmployeesUseCase>(
          create: (context) =>
              GetEmployeesUseCase(context.read<EmployeesRepository>()),
        ),
        Provider<CreateEmployeeUseCase>(
          create: (context) =>
              CreateEmployeeUseCase(context.read<EmployeesRepository>()),
        ),
        ChangeNotifierProvider<EmployeesProvider>(
          create: (context) =>
              EmployeesProvider(
                context.read<GetEmployeesUseCase>(),
                context.read<CreateEmployeeUseCase>(),
              ),
        ),
        Provider<KpisRemoteDataSource>(
          create: (context) => KpisRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<KpisRepository>(
          create: (context) =>
              KpisRepositoryImpl(context.read<KpisRemoteDataSource>()),
        ),
        Provider<GetKpisUseCase>(
          create: (context) => GetKpisUseCase(context.read<KpisRepository>()),
        ),
        Provider<GetActiveKpisUseCase>(
          create: (context) =>
              GetActiveKpisUseCase(context.read<KpisRepository>()),
        ),
        Provider<CreateKpiUseCase>(
          create: (context) => CreateKpiUseCase(context.read<KpisRepository>()),
        ),
        ChangeNotifierProvider<KpisProvider>(
          create: (context) => KpisProvider(
            getKpis: context.read<GetKpisUseCase>(),
            getActiveKpis: context.read<GetActiveKpisUseCase>(),
            createKpi: context.read<CreateKpiUseCase>(),
          ),
        ),
        Provider<ReportsRemoteDataSource>(
          create: (context) =>
              ReportsRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<ReportsRepository>(
          create: (context) =>
              ReportsRepositoryImpl(context.read<ReportsRemoteDataSource>()),
        ),
        Provider<GetReportSummariesUseCase>(
          create: (context) =>
              GetReportSummariesUseCase(context.read<ReportsRepository>()),
        ),
        ChangeNotifierProvider<ReportsProvider>(
          create: (context) =>
              ReportsProvider(context.read<GetReportSummariesUseCase>()),
        ),
        Provider<ProjectsRemoteDataSource>(
          create: (context) =>
              ProjectsRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<ProjectsRepository>(
          create: (context) =>
              ProjectsRepositoryImpl(context.read<ProjectsRemoteDataSource>()),
        ),
        Provider<GetProjectsUseCase>(
          create: (context) =>
              GetProjectsUseCase(context.read<ProjectsRepository>()),
        ),
        Provider<GetProjectMembersUseCase>(
          create: (context) =>
              GetProjectMembersUseCase(context.read<ProjectsRepository>()),
        ),
        Provider<AddProjectMemberUseCase>(
          create: (context) =>
              AddProjectMemberUseCase(context.read<ProjectsRepository>()),
        ),
        Provider<CreateProjectUseCase>(
          create: (context) =>
              CreateProjectUseCase(context.read<ProjectsRepository>()),
        ),
        ChangeNotifierProvider<ProjectsProvider>(
          create: (context) =>
              ProjectsProvider(
                context.read<GetProjectsUseCase>(),
                context.read<CreateProjectUseCase>(),
              ),
        ),
        Provider<EvaluationsRemoteDataSource>(
          create: (context) =>
              EvaluationsRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<EvaluationsRepository>(
          create: (context) => EvaluationsRepositoryImpl(
            context.read<EvaluationsRemoteDataSource>(),
          ),
        ),
        Provider<CreateEvaluationUseCase>(
          create: (context) =>
              CreateEvaluationUseCase(context.read<EvaluationsRepository>()),
        ),
        Provider<GetEvaluationUseCase>(
          create: (context) =>
              GetEvaluationUseCase(context.read<EvaluationsRepository>()),
        ),
        Provider<SubmitEvaluationUseCase>(
          create: (context) =>
              SubmitEvaluationUseCase(context.read<EvaluationsRepository>()),
        ),
        ChangeNotifierProvider<EvaluationsProvider>(
          create: (context) => EvaluationsProvider(
            createEvaluation: context.read<CreateEvaluationUseCase>(),
            getEvaluation: context.read<GetEvaluationUseCase>(),
            submitEvaluation: context.read<SubmitEvaluationUseCase>(),
          ),
        ),
        Provider<ApprovalsRemoteDataSource>(
          create: (context) =>
              ApprovalsRemoteDataSource(context.read<ApiClient>()),
        ),
        Provider<ApprovalsRepository>(
          create: (context) => ApprovalsRepositoryImpl(
            context.read<ApprovalsRemoteDataSource>(),
          ),
        ),
        Provider<GetApprovalUseCase>(
          create: (context) =>
              GetApprovalUseCase(context.read<ApprovalsRepository>()),
        ),
        Provider<GetApprovalsUseCase>(
          create: (context) =>
              GetApprovalsUseCase(context.read<ApprovalsRepository>()),
        ),
        Provider<ActOnApprovalUseCase>(
          create: (context) =>
              ActOnApprovalUseCase(context.read<ApprovalsRepository>()),
        ),
        ChangeNotifierProvider<ApprovalsProvider>(
          create: (context) => ApprovalsProvider(
            getApproval: context.read<GetApprovalUseCase>(),
            getApprovals: context.read<GetApprovalsUseCase>(),
            actOnApproval: context.read<ActOnApprovalUseCase>(),
          ),
        ),
      ],
      child: const KPIApp(),
    );
  }
}

class KPIApp extends StatelessWidget {
  const KPIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KPI Mobile App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D6A),
          surface: const Color(0xFFF7F6F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status == AuthStatus.unknown || auth.isLoading) {
          return const SplashPage();
        }
        if (auth.status == AuthStatus.authenticated) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
