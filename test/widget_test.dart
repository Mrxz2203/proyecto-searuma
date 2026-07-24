import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:searuma/providers/character_provider.dart';
import 'package:searuma/router/app_router.dart';

void main() {
  testWidgets('App loads welcome page', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CharacterProvider(),
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    expect(find.text('Welcome Page'), findsOneWidget);
  });
}