import 'package:money_tracker/Screen/add_expenses.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Map<String, dynamic>> expenses = [];
  bool isLoading = true;
  late int userid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0075DB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenses.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first expense using the + button',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0075DB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.money,
                            color: Color(0xFF0075DB),
                          ),
                        ),
                        title: Text(
                          '₹${expense['amount']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${expense['category']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Date: ${expense['date']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const Addexpenses()));
          if (result == true) {
            fetchExpenses();
          }
        },
        backgroundColor: const Color(0xFF0075DB),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> fetchExpenses() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getInt('user_id') ?? 0;

      if (userid == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please login again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final url =
          'https://localhost:7007/api/Expense/GetByUserId?userid=$userid';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          expenses =
              data.map((expense) {
                return {
                  'amount': expense['amount'].toString(),
                  'category': expense['category'] ?? 'Uncategorized',
                  'date': expense['date'] ?? 'No date',
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }
}
