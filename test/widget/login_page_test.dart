
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:kpi_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:kpi_mobile_app/features/auth/presentation/providers/auth_provider.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuthProvider,
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    // arrange
    when(mockAuthProvider.isLoading).thenReturn(false);
    await tester.pumpWidget(createWidgetUnderTest());

    // assert
    expect(find.text('KPI Mobile'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
    // arrange
    when(mockAuthProvider.isLoading).thenReturn(false);
    await tester.pumpWidget(createWidgetUnderTest());

    // act
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters long'), findsOneWidget);
  });

  testWidgets('should call login on auth provider when form is valid', (WidgetTester tester) async {
    // arrange
    final tEmail = 'test@test.com';
    final tPassword = 'password';
    when(mockAuthProvider.isLoading).thenReturn(false);
    when(mockAuthProvider.login(email: tEmail, password: tPassword)).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    // act
    await tester.enterText(find.byType(TextFormField).first, tEmail);
    await tester.enterText(find.byType(TextFormField).last, tPassword);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // assert
    verify(mockAuthProvider.login(email: tEmail, password: tPassword));
  });

  testWidgets('should show snackbar on login failure', (WidgetTester tester) async {
    // arrange
    final tEmail = 'test@test.com';
    final tPassword = 'password';
    final errorMessage = 'Invalid credentials';
    when(mockAuthProvider.isLoading).thenReturn(false);
    when(mockAuthProvider.login(email: tEmail, password: tPassword)).thenAnswer((_) async => false);
    when(mockAuthProvider.error).thenReturn(errorMessage);

    await tester.pumpWidget(createWidgetUnderTest());

    // act
    await tester.enterText(find.byType(TextFormField).first, tEmail);
    await tester.enterText(find.byType(TextFormField).last, tPassword);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // assert
    expect(find.text(errorMessage), findsOneWidget);
  });
}
