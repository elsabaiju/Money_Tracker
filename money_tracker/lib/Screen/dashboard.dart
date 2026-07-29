import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _totalDebts = 0;
  double _totalExpenses = 0;
  bool _isLoading = true;

  late int _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchTotals();
  }

  Future<void> _loadUserIdAndFetchTotals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
    await _fetchTotals();
  }

  Future<void> _fetchTotals() async {
    setState(() {
      _isLoading = true;
    });

    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    try {
      // ---- Fetch Debts ----
      final debtRes = await http.post(
        Uri.parse("https://localhost:7007/api/Debt/byuserid?userId=$_userId"),
        headers: {'Content-Type': 'application/json'},
      );

      double sumDebts = 0;
      if (debtRes.statusCode == 200) {
        List debts = jsonDecode(debtRes.body);
        for (var d in debts) {
          if (d['date'] != null) {
            DateTime date = DateTime.parse(d['date']);
            if (date.month == currentMonth && date.year == currentYear) {
              sumDebts += (d['amount'] ?? 0).toDouble();
            }
          }
        }
      }

      // ---- Fetch Expenses ----
      final expRes = await http.post(
        Uri.parse(
            "https://localhost:7007/api/Expense/GetByUserId?userid=$_userId"),
        headers: {'Content-Type': 'application/json'},
      );

      double sumExpenses = 0;
      if (expRes.statusCode == 200) {
        List expenses = jsonDecode(expRes.body);
        for (var e in expenses) {
          if (e['date'] != null) {
            DateTime date = DateTime.parse(e['date']);
            if (date.month == currentMonth && date.year == currentYear) {
              sumExpenses += (e['amount'] ?? 0).toDouble();
            }
          }
        }
      }

      setState(() {
        _totalDebts = sumDebts;
        _totalExpenses = sumExpenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching totals: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [
        Color(0xFFb3d4fc),
        Color(0xFF6ba8ef),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(top: 56.0, bottom: 24),
                        child: Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      Text(
                        "Select an option to manage your money.",
                        style: TextStyle(
                            fontSize: 16, color: Colors.blueGrey[700]),
                      ),
                      const SizedBox(height: 36),

                      // Dashboard buttons
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 28,
                        runSpacing: 28,
                        children: const [
                          _DashboardCard(
                            label: "Expenses",
                            icon: Icons.account_balance_wallet_outlined,
                            route: "/expenses",
                          ),
                          _DashboardCard(
                            label: "Debts",
                            icon: Icons.money_off_outlined,
                            route: "/your-debts",
                          ),
                          _DashboardCard(
                            label: "Notes",
                            icon: Icons.notes_outlined,
                            route: "/notes",
                          ),
                          _DashboardCard(
                            label: "Calendar",
                            icon: Icons.calendar_today_outlined,
                            route: "/calendar",
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Monthly Budget Section
                      BudgetLimitWidget(
                        totalDebts: _totalDebts,
                        totalExpenses: _totalExpenses,
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String route;

  const _DashboardCard({
    required this.label,
    required this.icon,
    required this.route,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 180,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(_isHovered ? 0.25 : 0.12),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.pushNamed(context, widget.route),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 42, color: Colors.blue[700]),
                const SizedBox(height: 14),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Budget Limit Widget is same as before
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
    double availableIncome =
        _monthlyIncome - (widget.totalDebts + widget.totalExpenses);
    bool isLimitExceeded =
        _expenseLimit > 0 && widget.totalExpenses > _expenseLimit;

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
                Text('Total Debts: ₹${widget.totalDebts.toStringAsFixed(2)}'),
                Text(
                    'Total Expenses: ₹${widget.totalExpenses.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
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
