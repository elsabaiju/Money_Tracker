import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetLimitWidget extends StatefulWidget {
  final double totalDebts;
  final double totalExpenses;

  const BudgetLimitWidget({
    super.key,
    required this.totalDebts,
    required this.totalExpenses,
  });

  @override
  State<BudgetLimitWidget> createState() => _BudgetLimitWidgetState();
}

class _BudgetLimitWidgetState extends State<BudgetLimitWidget> {
  late TextEditingController _incomeController;
  late TextEditingController _limitController;

  double _monthlyIncome = 0;
  double _expenseLimit = 0;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController();
    _limitController = TextEditingController();
    _loadSavedBudget();
  }

  Future<void> _loadSavedBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyIncome = prefs.getDouble('monthly_income') ?? 0;
      _expenseLimit = prefs.getDouble('expense_limit') ?? 0;
      _incomeController.text =
          _monthlyIncome > 0 ? _monthlyIncome.toString() : '';
      _limitController.text = _expenseLimit > 0 ? _expenseLimit.toString() : '';
    });
  }

  Future<void> _saveBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double income = double.tryParse(_incomeController.text) ?? 0;
    double limit = double.tryParse(_limitController.text) ?? 0;

    await prefs.setDouble('monthly_income', income);
    await prefs.setDouble('expense_limit', limit);

    setState(() {
      _monthlyIncome = income;
      _expenseLimit = limit;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalDebts = widget.totalDebts;
    double totalExpenses = widget.totalExpenses;
    double availableIncome = _monthlyIncome - (totalDebts + totalExpenses);

    bool isLimitExceeded = _expenseLimit > 0 && totalExpenses > _expenseLimit;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _incomeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Set Monthly Income',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveBudget(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _limitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Set Monthly Expense Limit',
                prefixIcon: Icon(Icons.money_off),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveBudget(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Debts: ₹${totalDebts.toStringAsFixed(2)}'),
                Text('Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),
            Text(
              'Available Income: ₹${availableIncome.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: availableIncome >= 0 ? Colors.green : Colors.redAccent,
              ),
            ),
            if (isLimitExceeded)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: You have exceeded your monthly expense limit!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
