import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class FinancialItem {
  final String type;
  final String title;
  final double? amount;
  final String description;

  FinancialItem({
    required this.type,
    required this.title,
    this.amount,
    required this.description,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<FinancialItem>> events = {};
  DateTime _selectedDay = DateTime.now();
  late int userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id') ?? 0;

    await Future.wait([
      fetchDebts(),
      fetchExpenses(),
      fetchNotes(),
    ]);

    setState(() {});
  }

  // ---- Fetch Debts ----
  Future<void> fetchDebts() async {
    final uri =
        Uri.parse("https://localhost:7007/api/Debt/byuserid?userId=$userId");
    final res =
        await http.post(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      for (var debt in data) {
        DateTime date = DateTime.parse(debt['date']);
        _addEvent(
          date,
          FinancialItem(
            type: 'debt',
            title: debt['name'] ?? 'Debt',
            amount: (debt['amount'] ?? 0).toDouble(),
            description: debt['description'] ?? '',
          ),
        );
      }
    }
  }

  // ---- Fetch Expenses ----
  Future<void> fetchExpenses() async {
    final uri =
        Uri.parse("https://localhost:7007/api/Expense/byuserid?userId=$userId");
    final res =
        await http.post(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      for (var exp in data) {
        DateTime date = DateTime.parse(exp['date']);
        _addEvent(
          date,
          FinancialItem(
            type: 'expense',
            title: exp['category'] ?? 'Expense',
            amount: (exp['amount'] ?? 0).toDouble(),
            description: exp['description'] ?? '',
          ),
        );
      }
    }
  }

  // ---- Fetch Notes ----
  Future<void> fetchNotes() async {
    final uri =
        Uri.parse("https://localhost:7007/api/Note/byuserid?userId=$userId");
    final res =
        await http.post(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      for (var note in data) {
        DateTime date = DateTime.parse(note['date']);
        _addEvent(
          date,
          FinancialItem(
            type: 'note',
            title: note['notes'].split(' ').take(4).join(' '),
            description: note['notes'],
          ),
        );
      }
    }
  }

  // ---- Helper to add events to the map ----
  void _addEvent(DateTime date, FinancialItem item) {
    final key = DateTime.utc(date.year, date.month, date.day);
    if (events[key] == null) {
      events[key] = [item];
    } else {
      events[key]!.add(item);
    }
  }

  List<FinancialItem> _getEventsForDay(DateTime day) {
    return events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = LinearGradient(
      colors: [
        const Color.fromARGB(255, 244, 245, 246),
        const Color.fromARGB(255, 250, 251, 252)
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 126, 229),
        title: const Text("Calendar"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            TableCalendar<FinancialItem>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _selectedDay = selectedDay);
                final dayEvents = _getEventsForDay(selectedDay);
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ListView(
                    children: dayEvents
                        .map((event) => ListTile(
                              leading: Icon(
                                event.type == 'debt'
                                    ? Icons.money_off
                                    : event.type == 'note'
                                        ? Icons.notes
                                        : Icons.account_balance_wallet,
                                color: event.type == 'debt'
                                    ? Colors.red
                                    : event.type == 'note'
                                        ? Colors.blue
                                        : Colors.green,
                              ),
                              title: Text(event.title),
                              subtitle: Text(event.amount != null
                                  ? '₹${event.amount}'
                                  : event.description),
                            ))
                        .toList(),
                  ),
                );
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Color(0xFF0075DB),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
