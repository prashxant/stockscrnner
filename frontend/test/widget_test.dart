import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stock_screener/main.dart';
import 'package:stock_screener/features/auth/presentation/providers/auth_provider.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(FakeFirebaseAuth()),
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const StockScreenerApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
