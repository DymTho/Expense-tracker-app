import 'package:flutter/material.dart';

import '../../models/expense.dart';
import 'chart_bar.dart';

/// Bar chart of spending per category. Each bar's height is its category's
/// total relative to the biggest category. Tapping a bar calls [onBucketTap].
class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.expenses,
    this.onBucketTap,
    this.isGlass = false,
  });

  final List<Expense> expenses;
  final void Function(ExpenseBucket bucket)? onBucketTap;
  final bool isGlass;

  /// One bucket per category, in enum order (also when a category is empty).
  List<ExpenseBucket> get buckets {
    return [
      for (final category in Category.values)
        ExpenseBucket.forCategory(expenses, category),
    ];
  }

  /// The largest category total, used to scale the bars to 0..1.
  /// Returns 1 when there are no expenses to avoid dividing by zero.
  double get _maxTotalExpense {
    double max = 0;
    for (final bucket in buckets) {
      if (bucket.totalExpenses > max) {
        max = bucket.totalExpenses;
      }
    }
    return max == 0 ? 1 : max;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassColor = Colors.black.withValues(alpha: 0.32);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isGlass ? glassColor : null,
        border: isGlass
            ? Border.all(color: Colors.white.withValues(alpha: 0.18))
            : null,
        gradient: isGlass
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colorScheme.surfaceContainerHigh,
                        colorScheme.surfaceContainer,
                      ]
                    : [
                        colorScheme.primary.withValues(alpha: 0.12),
                        colorScheme.surface,
                      ],
              ),
        boxShadow: isGlass
            ? null
            : [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in buckets)
                  Expanded(
                    child: GestureDetector(
                      onTap: onBucketTap == null
                          ? null
                          : () => onBucketTap!(bucket),
                      child: ChartBar(
                        fill: bucket.totalExpenses / _maxTotalExpense,
                        color: categoryColors[bucket.category]!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final bucket in buckets)
                Expanded(
                  child: Icon(
                    categoryIcons[bucket.category],
                    color: isGlass
                        ? Colors.white.withValues(alpha: 0.85)
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
