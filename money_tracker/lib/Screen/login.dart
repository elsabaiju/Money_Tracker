import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 0, 117, 219),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Watermark image
        Positioned.fill(
          child: IgnorePointer( // Makes sure image doesn't block interaction
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/watermark.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),

        // Login form content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                const SizedBox(height: 50),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 13, 61),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Login to continue managing your money.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 40),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 16),
                _buildTextField(passwordController, "Password", Icons.lock, obscure: true),
                const SizedBox(height: 30),
                _buildButton("Login", () => _loginUser(context)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    final url = 'https://localhost:7007/api/Auth/login?Email=$email&Password=$password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        final int userId = data['userId'] ?? 0;
        final String username = data['username'] ?? '';
        final String message = data['message']?.toString().toLowerCase() ?? '';

        if (message.contains('success') && userId > 0 && username.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $message')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
