import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/theme/theme_controller.dart';

void main() {
  testWidgets('App shows the empty state and can open the add-expense sheet',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeController = ThemeController();
    await themeController.load();

    await tester.pumpWidget(
      ExpenseTrackerApp(themeController: themeController),
    );
    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_rounded));
    await tester.pumpAndSettle();

    expect(find.text('New Expense'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('Deleting the last expense refreshes the screen (NOK amounts)',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'expenses': jsonEncode([
        Expense(
          title: 'Lunch',
          amount: 129.5,
          date: DateTime(2026, 9, 17),
          category: Category.food,
        ).toJson(),
      ]),
    });
    final themeController = ThemeController();
    await themeController.load();

    await tester.pumpWidget(
      ExpenseTrackerApp(themeController: themeController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.textContaining('kr'), findsWidgets);
    expect(find.textContaining('\$'), findsNothing);

    await tester.drag(find.text('Lunch'), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsNothing);
    expect(find.text('No expenses yet'), findsOneWidget);
  });
}
