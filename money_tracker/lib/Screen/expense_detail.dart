import 'package:flutter/material.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0075DB),
        title: Text(expense['name'] ?? 'Expense Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailCard(
                children: [
                  _buildDetailItem('Amount', '₹${expense['amount']}'),
                  _buildDetailItem('Category', expense['category'] ?? 'N/A'),
                  _buildDetailItem(
                    'Date',
                    expense['date'] != null
                        ? _formatDate(expense['date'].toString())
                        : 'No date',
                  ),
                  _buildDetailItem(
                    'Payment Method',
                    expense['paymentMethod']?.toString() ?? 'N/A',
                  ),
                  _buildDetailItem(
                    'Description',
                    expense['description']?.toString() ?? 'No description',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0075DB),
        onPressed: () => Navigator.pop(context, true),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
