import 'package:flutter/material.dart';
import 'package:money_tracker/Screen/YourDebts.dart';
import 'package:money_tracker/Screen/create_debt.dart';
import 'package:money_tracker/Screen/dashboard.dart';
import 'package:money_tracker/Screen/expenses.dart';
import 'package:money_tracker/Screen/login.dart';
import 'package:money_tracker/Screen/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/Screen/add_expenses.dart';
import 'package:money_tracker/Screen/debt_detail.dart';
import 'package:money_tracker/Screen/notes.dart';
import 'package:money_tracker/Screen/table_calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  runApp(MyApp(initialRoute: userId != null ? '/dashboard' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const Login(),
        '/register':(context) => const Register(),
        '/dashboard': (context) => const Dashboard(),
        '/your-debts': (context) => const YourDebts(),
        '/expenses': (context) => const Expenses(),
        '/create-debt': (context) => const CreateDebtScreen(),
        '/add-expense': (context) => const Addexpenses(),
        '/notes': (context) => const Notes(),
        '/calendar': (context) => const CalendarScreen(),
        '/debt-detail': (context) => DebtDetailScreen(
              debt: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
      },
    );
  }
}
