import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Addexpenses extends StatefulWidget {
  const Addexpenses({super.key});

  @override
  State<Addexpenses> createState() => _AddexpensesState();
}

class _AddexpensesState extends State<Addexpenses>
    with SingleTickerProviderStateMixin {
  final TextEditingController amountcontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  final TextEditingController categorycontroller = TextEditingController();
  final TextEditingController datecontroller = TextEditingController();

  int? userId;
  bool _amountError = false;
  bool _categoryError = false;
  bool _descriptionError = false;
  bool _dateError = false;
  bool _showCheckmark = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB3E5FC), Color(0xFF0288D1)],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 60,
                ),
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 12,
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '💸 New Expense',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              amountcontroller,
                              'Amount',
                              icon: Icons.attach_money,
                              error: _amountError,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),
                            _buildTextField(
                              categorycontroller,
                              'Category',
                              icon: Icons.category,
                              error: _categoryError,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),
                            _buildTextField(
                              descriptioncontroller,
                              'Description',
                              icon: Icons.description,
                              error: _descriptionError,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),
                            TextField(
                              controller: datecontroller,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Select date",
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor:
                                    isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        _dateError
                                            ? Colors.red
                                            : Colors.transparent,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  setState(() {
                                    datecontroller.text = formattedDate;
                                    _dateError = false;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _addexpenses(context),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Add Expense'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_showCheckmark)
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: _showCheckmark ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(30),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool isDark = false,
    bool error = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Future<void> _addexpenses(BuildContext context) async {
    String amountText = amountcontroller.text.trim();
    String category = categorycontroller.text.trim();
    String description = descriptioncontroller.text.trim();
    String date = datecontroller.text.trim();

    double? amount = double.tryParse(amountText);

    setState(() {
      _amountError = amount == null;
      _categoryError = category.isEmpty;
      _descriptionError = description.isEmpty;
      _dateError = date.isEmpty;
    });

    if (_amountError ||
        _categoryError ||
        _descriptionError ||
        _dateError ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid data in all fields')),
      );
      return;
    }

    String url =
        'https://localhost:7007/api/Expense/add?userid=$userId&date=$date&amount=$amount&category=$category&description=$description';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _showCheckmark = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _showCheckmark = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Expense added!')));
        Navigator.pushReplacementNamed(context, '/expenses');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
