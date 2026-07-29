import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateDebtScreen extends StatefulWidget {
  const CreateDebtScreen({super.key});

  @override
  State<CreateDebtScreen> createState() => _CreateDebtScreenState();
}

class _CreateDebtScreenState extends State<CreateDebtScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int? userId;

  bool _nameError = false;
  bool _dateError = false;
  bool _amountError = false;
  bool _categoryError = false;
  bool _deadlineError = false;
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    bool error = false,
    IconData? icon,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (controller == dateController) _dateError = false;
        if (controller == deadlineController) _deadlineError = false;
      });
    }
  }

  Future<void> createDebt() async {
    final name = nameController.text.trim();
    final date = dateController.text.trim();
    final amount = amountController.text.trim();
    final category = categoryController.text.trim();
    final deadline = deadlineController.text.trim();
    final description = descriptionController.text.trim();

    setState(() {
      _nameError = name.isEmpty;
      _dateError = date.isEmpty;
      _amountError = amount.isEmpty;
      _categoryError = category.isEmpty;
      _deadlineError = deadline.isEmpty;
    });

    if (_nameError ||
        _dateError ||
        _amountError ||
        _categoryError ||
        _deadlineError ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final url = Uri.parse(
      'https://localhost:7007/api/Debt/create'
      '?name=$name&userid=$userId&date=$date&amount=$amount'
      '&category=$category&deadline=$deadline&description=$description',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          _showCheckmark = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _showCheckmark = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debt created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
          'Create Debt',
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
                colors: [
                  Color(0xFFB3E5FC),
                  Color(0xFF0288D1)
                ], // Matches Addexpenses
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '💸 New Debt', // Icon & style matches Addexpenses
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              nameController,
                              'Name',
                              error: _nameError,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              dateController,
                              'Date',
                              readOnly: true,
                              onTap: () => _selectDate(dateController),
                              icon: Icons.calendar_today,
                              error: _dateError,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              amountController,
                              'Amount',
                              icon: Icons.attach_money,
                              error: _amountError,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              categoryController,
                              'Category',
                              icon: Icons.category,
                              error: _categoryError,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              deadlineController,
                              'Deadline',
                              readOnly: true,
                              onTap: () => _selectDate(deadlineController),
                              icon: Icons.calendar_today,
                              error: _deadlineError,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              descriptionController,
                              'Description',
                              icon: Icons.description,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: createDebt,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Save Debt'),
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
}
