import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

/// Saves and loads the expense list on the device, so data survives app
/// restarts. The whole list is stored as one JSON string in SharedPreferences.
class ExpenseStorage {
  static const _storageKey = 'expenses';

  /// Reads the saved expenses. Returns an empty list on first launch.
  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Overwrites the saved data with the current [expenses]. Called after
  /// every add, delete and undo.
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
