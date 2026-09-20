import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMMMd();
final _moneyFormatter = NumberFormat.currency(locale: 'nb_NO', symbol: 'kr');

String formatMoney(double amount) => _moneyFormatter.format(amount);

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

class Expense {
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
      };

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

class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});

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
