import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_flutter_app/main.dart';

void main() {
  testWidgets('supports full expense CRUD flow', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpensesApp());

    expect(find.text('Aucune dépense pour le moment'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('expense-form-title')),
      'Courses',
    );
    await tester.enterText(
      find.byKey(const Key('expense-form-amount')),
      '24.50',
    );
    await tester.enterText(
      find.byKey(const Key('expense-form-note')),
      'Supermarché',
    );
    await tester.tap(find.byKey(const Key('expense-form-submit')));
    await tester.pumpAndSettle();

    final courseTitle = find.text('Courses').last;
    await tester.scrollUntilVisible(courseTitle, 500);
    expect(courseTitle, findsOneWidget);
    expect(find.text('24.50 €'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Modifier'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('expense-form-amount')),
      '30.00',
    );
    await tester.tap(find.byKey(const Key('expense-form-submit')));
    await tester.pumpAndSettle();

    expect(find.text('30.00 €'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Aucune dépense pour le moment'), findsOneWidget);
  });
}
