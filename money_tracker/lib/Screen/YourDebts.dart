import 'package:money_tracker/Screen/create_debt.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class YourDebts extends StatefulWidget {
  const YourDebts({super.key});

  @override
  State<YourDebts> createState() => _YourDebtsState();
}

class _YourDebtsState extends State<YourDebts> {
  List<Map<String, dynamic>> debts = [];
  bool isLoading = true;
  late int userid;
  String? fromDate;
  String? toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        final formattedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isFromDate) {
          fromDate = formattedDate;
        } else {
          toDate = formattedDate;
        }
      });
      fetchDebts();
    }
  }

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
          'Debts',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Filter by Date'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(fromDate ?? 'Select From Date'),
                            leading: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                          ),
                          ListTile(
                            title: Text(toDate ?? 'Select To Date'),
                            leading: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              fromDate = null;
                              toDate = null;
                            });
                            fetchDebts();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
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
                : debts.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fromDate != null || toDate != null
                            ? 'No debts found for selected dates'
                            : 'No debts yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/debt-detail',
                          arguments: debt,
                        );

                        if (result == true) {
                          fetchDebts(); // Refresh the list after returning
                        }
                      },

                      child: Card(
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
                              Icons.account_balance_wallet,
                              color: Color(0xFF0075DB),
                            ),
                          ),
                          title: Text(
                            '₹${debt['amount']}',
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
                                'Category: ${debt['category']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Deadline: ${debt['deadline']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateDebtScreen()),
          );
          if (result == true) {
            fetchDebts();
          }
        },
        backgroundColor: const Color(0xFF0075DB),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> fetchDebts() async {
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

      final Uri url;
      Map<String, dynamic> body;

      if (fromDate != null && toDate != null) {
        url = Uri.parse("https://localhost:7007/api/Debt/GetFilteredDebts");
        body = {
          "userId": userid,
          "fromDate": fromDate,
          "toDate": toDate,
        };
      } else {
        url = Uri.parse("https://localhost:7007/api/Debt/getByUserId?userid=$userid");
        body = {"userId": userid};
      }

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          debts =
              data.map((debt) {
                return {
                  'amount': debt['amount'].toString(),
                  'category': debt['category'] ?? 'Uncategorized',
                  'deadline': debt['deadline'] ?? 'No deadline',
                  'name': debt['name'] ?? 'Unnamed',
                  'date': debt['date'] ?? 'No date',
                  'description': debt['description'] ?? 'No description',
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load debts: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDebts();
  }
}
