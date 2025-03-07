import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  Map<String, double> categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _calculateSummary();
  }

  Future<void> _calculateSummary() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Handle case where user is not logged in
      return;
    }

    final transactions = await FirebaseFirestore.instance
        .collection('users') // Users collection
        .doc(userId) // Document with user's UID
        .collection('transactions') // Sub-collection for transactions
        .get(); // Get all transaction documents for this user

    double balance = 0.0, income = 0.0, expenses = 0.0;

    // Reset category expenses for each calculation
    categoryExpenses = {};

    // Iterate through each transaction document
    for (var doc in transactions.docs) {
      final data = doc.data();
      final amount = data['amount'] ?? 0.0;
      final type = data['type'] ?? '';
      final category = data['category'] ?? '';

      if (type == 'Income') {
        income += amount;
        balance += amount;
      } else if (type == 'Expense') {
        expenses += amount;
        balance -= amount;

        // Group expenses by category
        if (categoryExpenses.containsKey(category)) {
          categoryExpenses[category] = categoryExpenses[category]! + amount;
        } else {
          categoryExpenses[category] = amount;
        }
      }
    }

    if (mounted) {
      setState(() {
        totalBalance = balance;
        totalIncome = income;
        totalExpenses = expenses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('Income', totalIncome, Colors.green),
                _buildSummaryCard('Expenses', totalExpenses, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Expense Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Pie chart widget
            categoryExpenses.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getPieChartSections(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  )
                : const Center(child: Text('No expenses recorded')),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions')
                    .then((_) => _calculateSummary()),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('View Transactions'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/loginSignup');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addTransaction')
            .then((_) => _calculateSummary()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    List<PieChartSectionData> sections = [];
    categoryExpenses.forEach((category, amount) {
      sections.add(PieChartSectionData(
        value: amount,
        color: _getCategoryColor(category),
        title: category,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    });
    return sections;
  }

  Color _getCategoryColor(String category) {
    // You can define specific colors for categories here.
    switch (category) {
      case 'Food':
        return Colors.blue;
      case 'Transport':
        return Colors.orange;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
