import 'package:flutter/material.dart';

import '../../models/expense.dart';
import 'expense_item.dart';

/// Wraps a single [ExpenseItem] with the enter/exit animation used by the
/// surrounding [AnimatedList], and optionally makes it swipe-to-delete.
class AnimatedExpenseRow extends StatelessWidget {
  const AnimatedExpenseRow({
    super.key,
    required this.expense,
    required this.animation,
    this.onDismissed,
  });

  final Expense expense;
  final Animation<double> animation;
  final void Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ExpenseItem(expense: expense),
    );

    final row = onDismissed == null
        ? content
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Dismissible(
              key: ValueKey(expense.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) => onDismissed!(),
              child: ExpenseItem(expense: expense),
            ),
          );

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: row),
    );
  }
}
