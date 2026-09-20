import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMMMd();
final _moneyFormatter = NumberFormat.currency(locale: 'nb_NO', symbol: 'kr');

/// Formats an amount as Norwegian kroner, e.g. `1 234,50 kr`.
String formatMoney(double amount) => _moneyFormatter.format(amount);

/// Spending categories, used by the add-expense form, the list and the chart.
enum Category { food, transport, leisure, work, shopping }

const categoryIcons = {
  Category.food: Icons.lunch_dining_rounded,
  Category.transport: Icons.directions_car_filled_rounded,
  Category.leisure: Icons.movie_filter_rounded,
  Category.work: Icons.work_rounded,
  Category.shopping: Icons.shopping_bag_rounded,
};

const categoryLabels = {
  Category.food: 'Food',
  Category.transport: 'Transport',
  Category.leisure: 'Leisure',
  Category.work: 'Work',
  Category.shopping: 'Shopping',
};

const categoryColors = {
  Category.food: Color(0xFFFF8A65),
  Category.transport: Color(0xFF4FC3F7),
  Category.leisure: Color(0xFFBA68C8),
  Category.work: Color(0xFF81C784),
  Category.shopping: Color(0xFFFFD54F),
};

/// A single expense. This is the app's data model.
class Expense {
  /// A new expense gets a random unique [id] unless one is passed in
  /// (which happens when an expense is loaded from storage).
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate => formatter.format(date);

  /// Converts the expense to a JSON-friendly map so it can be saved as text.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
      };

  /// Rebuilds an expense from the map produced by [toJson].
  /// Falls back to [Category.leisure] if the saved category is unknown.
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        category: Category.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => Category.leisure,
        ),
      );
}

/// All expenses that belong to one [Category]. The chart draws one bar
/// per bucket, sized by [totalExpenses].
class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});

  /// Picks the expenses of [category] out of [allExpenses].
  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses =
            allExpenses.where((expense) => expense.category == category).toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
