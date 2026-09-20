import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_storage.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'chart/chart.dart';
import 'expenses_list/expenses_list.dart';
import 'new_expense.dart';
import 'settings_screen.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<Expense> _registeredExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await ExpenseStorage.loadExpenses();
    setState(() {
      _registeredExpenses.addAll(expenses);
      _isLoading = false;
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.insert(0, expense);
    });
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 350),
    );
    ExpenseStorage.saveExpenses(_registeredExpenses);
  }

  void _removeExpense(Expense expense) {
    final index = _registeredExpenses.indexOf(expense);
    if (index == -1) return;

    _registeredExpenses.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => AnimatedExpenseRow(
        expense: expense,
        animation: animation,
      ),
      duration: const Duration(milliseconds: 300),
    );
    setState(() {});
    ExpenseStorage.saveExpenses(_registeredExpenses);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            final listState = _listKey.currentState;
            setState(() {
              _registeredExpenses.insert(index, expense);
            });
            listState?.insertItem(index);
            ExpenseStorage.saveExpenses(_registeredExpenses);
          },
        ),
      ),
    );
  }

  void _showCategoryTotal(ExpenseBucket bucket) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${categoryLabels[bucket.category]}: '
          '${formatMoney(bucket.totalExpenses)}',
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final expense = _registeredExpenses[index];
    return AnimatedExpenseRow(
      expense: expense,
      animation: animation,
      onDismissed: () => _removeExpense(expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 600;
    final preset = ThemeScope.of(context).preset;
    final isGlass = preset.hasPhotoBackground;

    Widget mainContent;
    if (_isLoading) {
      mainContent = const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    } else if (_registeredExpenses.isEmpty) {
      mainContent = KeyedSubtree(
        key: const ValueKey('loaded'),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 350),
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: _EmptyState(isGlass: isGlass),
        ),
      );
    } else {
      final chart = Chart(
        expenses: _registeredExpenses,
        onBucketTap: _showCategoryTotal,
        isGlass: isGlass,
      );
      final list = AnimatedList(
        key: _listKey,
        initialItemCount: _registeredExpenses.length,
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        itemBuilder: _buildListItem,
      );

      mainContent = KeyedSubtree(
        key: const ValueKey('loaded'),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: chart),
                  Expanded(child: list),
                ],
              )
            : Column(
                children: [
                  chart,
                  Expanded(child: list),
                ],
              ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: isGlass,
      appBar: AppBar(
        backgroundColor: isGlass ? Colors.transparent : null,
        flexibleSpace: isGlass
            ? null
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                ),
              ),
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.palette_rounded, size: 26),
            tooltip: 'Theme settings',
          ),
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add_circle_rounded, size: 28),
            tooltip: 'Add expense',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          if (preset.hasPhotoBackground)
            _BackgroundPhoto(preset: preset),
          SafeArea(
            top: !isGlass,
            child: Padding(
              padding: EdgeInsets.only(
                top: isGlass
                    ? MediaQuery.paddingOf(context).top + kToolbarHeight
                    : 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: mainContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPhoto extends StatelessWidget {
  const _BackgroundPhoto({required this.preset});

  final AppThemePreset preset;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Stack(
          key: ValueKey(preset.id),
          fit: StackFit.expand,
          children: [
            Image.asset(
              preset.backgroundAsset!,
              fit: BoxFit.cover,
              alignment: preset.backgroundAlignment,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    for (final alpha in preset.scrimAlphas)
                      preset.scrimColor.withValues(alpha: alpha),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isGlass});

  final bool isGlass;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isGlass ? Colors.white : colorScheme.onSurface;
    final iconColor = isGlass ? Colors.white : colorScheme.primary;

    return Center(
      key: const ValueKey('empty-state'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isGlass
                  ? Colors.white.withValues(alpha: 0.15)
                  : colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}
